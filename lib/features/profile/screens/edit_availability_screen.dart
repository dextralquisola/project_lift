import 'package:flutter/material.dart';
import 'package:project_lift/constants/styles.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:project_lift/widgets/app_textfield.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../service/profile_service.dart';
import '../utils/profle_utils.dart';

import '../../../widgets/app_button.dart';

class EditAvailabilityScreen extends StatefulWidget {
  const EditAvailabilityScreen({super.key});

  @override
  State<EditAvailabilityScreen> createState() => _EditAvailabilityScreenState();
}

class _EditAvailabilityScreenState extends State<EditAvailabilityScreen> {
  var data = [
    [
      {'day': 'Monday'},
      {'day': 'Tuesday'},
      {'day': 'Wednesday'},
    ],
    [
      {'day': 'Thursday'},
      {'day': 'Friday'},
      {'day': 'Saturday'},
    ],
  ];
  final _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  var _selectedDays = List.generate(6, (_) => false);
  var col = 0;

  final fromTimeController = TextEditingController();
  var fromTime = TimeOfDay.now();

  final toTimeController = TextEditingController();
  var toTime = TimeOfDay.now();

  var _isLoading = false;

  late UserProvider userProvider;

  final profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    if(userProvider.user.dateTimeAvailability.isNotEmpty) {
      initialize();
    }
  }

  @override
  Widget build(BuildContext context) {

    if(userProvider.user.dateTimeAvailability.isNotEmpty) {
      fromTimeController.text = fromTime.format(context);
      toTimeController.text = toTime.format(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Availability'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppText(
              text: "Select your schedule for the week",
              textSize: 20,
              textColor: Colors.black,
            ),
            const SizedBox(height: 20),
            Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                ...data.map(
                  (e) {
                    TableRow trBuilder() => TableRow(
                          children: [
                            ...e.map(
                              (e) {
                                return e['day'] == ''
                                    ? _emptyButtonBuilder()
                                    : _buttonBuilder(e);
                              },
                            )
                          ],
                        );
                    col++;
                    return trBuilder();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      TimeOfDay? newTime = await showTimePicker(
                        context: context,
                        initialTime: toTime,
                      );

                      if (newTime == null) return;

                      if (validateTimeOfDay(newTime)) {
                        _showSnackbar(
                            "Please select a time between 6:00 AM to 7:00 PM");
                        return;
                      }

                      setState(() {
                        fromTime = newTime;
                        fromTimeController.text = fromTime.format(context);
                      });
                    },
                    child: AppTextField(
                      controller: fromTimeController,
                      labelText: "From",
                      textInputType: TextInputType.datetime,
                      isEnabled: false,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (fromTimeController.text.isEmpty) {
                        _showSnackbar("Please select a 'from' time first");
                        return;
                      }

                      TimeOfDay? newTime = await showTimePicker(
                        context: context,
                        initialTime: toTime,
                      );

                      if (newTime == null) return;

                      if (!validateFromTimeOfDay(fromTime, newTime)) {
                        _showSnackbar(
                            "Please select a time after the 'from' time");
                        return;
                      }

                      setState(() {
                        toTime = newTime;
                        toTimeController.text = toTime.format(context);
                      });
                    },
                    child: AppTextField(
                      controller: toTimeController,
                      labelText: "To",
                      textInputType: TextInputType.datetime,
                      isEnabled: false,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppButton(
              wrapRow: true,
              height: 50,
              onPressed: () async {
                if (checkIfEmpty()) {
                  _showSnackbar("Please select at least one day and time");
                  return;
                }

                var dateTimeAvailability =
                    scheduleBuilder(_selectedDays, fromTime, toTime);

                setState(() {
                  _isLoading = true;
                });

                await profileService.updateUser(
                  context: context,
                  dateTimeAvailability: dateTimeAvailability,
                );

                Navigator.of(context).pop();
              },
              text: "Save Availability",
            ),
          ],
        ),
      ),
    );
  }

  void initialize() {
    final timeDayAvailableList = userProvider.user.dateTimeAvailability.split("+");

    final daysAvailable = timeDayAvailableList[0].split(".");
    final timeAvailable = timeDayAvailableList[1];

    final timeAvailableList = timeAvailable.split("-");
    final ft = timeAvailableList[0];
    final tt = timeAvailableList[1];

    fromTime = TimeOfDay(
        hour: int.parse(ft.split(":")[0]), minute: int.parse(ft.split(":")[1]));

    toTime = TimeOfDay(
        hour: int.parse(tt.split(":")[0]), minute: int.parse(tt.split(":")[1]));

    _selectedDays = daysSelectedBuilder(daysAvailable);
  }

  String scheduleBuilder(
    List<bool> selectedDays,
    TimeOfDay from,
    TimeOfDay to,
  ) {
    var fromTime = '${from.hour}:${from.minute}';
    var toTime = '${to.hour}:${to.minute}';

    return "${selectedDaysBuilder(selectedDays)}+$fromTime-$toTime";
  }

  _showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(
          text: text,
          textColor: Colors.white,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buttonBuilder(Map<String, String> e) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedDays[_days.indexOf(e['day']!)] =
                !_selectedDays[_days.indexOf(e['day']!)];
          });
        },
        style: ElevatedButton.styleFrom(
          primary: _selectedDays[_days.indexOf(e['day']!)]
              ? primaryColor
              : Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: AppText(
          text: e['day']!,
          textColor: _selectedDays[_days.indexOf(e['day']!)]
              ? Colors.white
              : Colors.black,
        ),
      ),
    );
  }

  Widget _emptyButtonBuilder() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
          Colors.transparent,
        )),
        child: AppText(text: ""),
      ),
    );
  }

  bool checkIfEmpty() {
    return _selectedDays.every((element) => element == false) &&
        fromTimeController.text.isEmpty &&
        toTimeController.text.isEmpty;
  }

  bool validateTimeOfDay(TimeOfDay timeOfDay) {
    return (timeOfDay.hour < 6) ||
        (timeOfDay.hour >= 19 && timeOfDay.minute >= 0);
  }

  bool validateFromTimeOfDay(TimeOfDay from, TimeOfDay to) {
    return from.hour < to.hour ||
        (from.hour == to.hour && from.minute < to.minute);
  }
}
