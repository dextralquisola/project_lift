import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_lift/features/study_pool/service/study_pool_service.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:project_lift/widgets/app_textfield.dart';
import 'package:provider/provider.dart';
import '../../../constants/constants.dart';
import '../../../constants/styles.dart';
import '../../../models/subject.dart';
import '../../../providers/user_provider.dart';

class CreateStudyRoomScreen extends StatefulWidget {
  const CreateStudyRoomScreen({super.key});

  @override
  State<CreateStudyRoomScreen> createState() => _CreateStudyRoomScreenState();
}

class _CreateStudyRoomScreenState extends State<CreateStudyRoomScreen> {
  final studyPoolService = StudyPoolService();

  late UserProvider userProvider;

  late Subject selectedSubject;
  late SubTopic selectedSubTopic;

  List<SubTopic> selectedSubTopics = [];

  List<DropdownMenuItem<Subject>> availableSubjects = [];
  List<DropdownMenuItem<SubTopic>> availableSubTopics = [];

  final studyNameController = TextEditingController();
  final locationController = TextEditingController();

  int _currentStep = 0;
  var studyRoomStatus = StudyRoomStatus.public;

  var fromTime = TimeOfDay.now();
  final fromTimeTextController = TextEditingController();

  var toTime = TimeOfDay.now();
  final toTimeTextController = TextEditingController();

  var selectedDate = DateTime.now();
  final selectedDateTextController = TextEditingController();

  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    super.dispose();
    studyNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Study Room'),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            children: [
              Expanded(
                child: Stepper(
                  type: StepperType.vertical,
                  physics: const ScrollPhysics(),
                  currentStep: _currentStep,
                  onStepTapped: (step) => tapped(step),
                  onStepContinue: _currentStep == 3 ? null : continued,
                  controlsBuilder: (context, details) {
                    return SizedBox(
                      width: double.maxFinite,
                      child: details.currentStep == 3
                          ? null
                          : Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                children: [
                                  AppButton(
                                    onPressed: details.onStepContinue!,
                                    bgColor: primaryColor,
                                    text: "Next",
                                  ),
                                  const SizedBox(width: 12),
                                  AppButton(
                                    bgColor: Colors.redAccent,
                                    onPressed: details.onStepCancel!,
                                    text: _currentStep == 0 ? "Cancel" : "Back",
                                  ),
                                ],
                              ),
                            ),
                    );
                  },
                  onStepCancel: cancel,
                  steps: [
                    Step(
                      title: AppText(text: 'Set study room name.'),
                      content: Column(
                        children: [
                          AppTextField(
                            controller: studyNameController,
                            labelText: "Study Room Name",
                          ),
                          const SizedBox(height: 10),
                          AppTextField(
                            controller: locationController,
                            labelText: "Study location",
                            hintText: 'e.g. Library, 3rd floor',
                          ),
                          const SizedBox(height: 10)
                        ],
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep == 0
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: AppText(text: "Select subject and sub-topics."),
                      content: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                            text: "Select subject",
                                            textSize: 17),
                                        DropdownButton(
                                          isExpanded: true,
                                          menuMaxHeight: 300,
                                          value: selectedSubject,
                                          items: availableSubjects,
                                          onChanged: (s) =>
                                              _onChangeSubject(s as Subject),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      AppText(
                                          text: "Selected subtopics",
                                          textSize: 17),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () async =>
                                            await _showSelectTopicDialog(
                                                context),
                                        icon: Icon(Icons.add,
                                            color: primaryColor),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: selectedSubTopics.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: AppText(
                                            text:
                                                selectedSubTopics[index].topic),
                                        trailing: IconButton(
                                          onPressed: () => removeSubTopic(
                                              selectedSubTopics[index]),
                                          icon: const Icon(Icons.remove,
                                              color: Colors.red),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep == 1
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: AppText(text: "Set meet schedule."),
                      content: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              DateTime? newDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2100),
                              );

                              if (newDate == null) return;

                              // ! Uncomment this after testing
                              // if (validateDate(newDate)) {
                              //   showSnackBar(context,
                              //       "You can't pick date from the past!");
                              //   return;
                              // }
                              // !

                              setState(() {
                                selectedDate = newDate;
                                selectedDateTextController.text =
                                    DateFormat('MMMM dd, yyyy').format(newDate);
                              });
                            },
                            child: AppTextField(
                              labelText: "Select date.",
                              controller: selectedDateTextController,
                              hintText: 'August 22, 2023',
                              isEnabled: false,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.maxFinite,
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      TimeOfDay? newTime = await showTimePicker(
                                        context: context,
                                        initialTime: fromTime,
                                      );

                                      if (newTime == null) return;
                                      if (validateTimeOfDay(newTime)) {
                                        showSnackBar(context,
                                            "Please select a time between 6:00 AM to 7:00 PM");
                                        return;
                                      }

                                      setState(() {
                                        fromTime = newTime;
                                        fromTimeTextController.text =
                                            fromTime.format(context);
                                      });
                                    },
                                    child: AppTextField(
                                      labelText: "From.",
                                      controller: fromTimeTextController,
                                      hintText: '5:00 AM',
                                      isEnabled: false,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      TimeOfDay? newTime = await showTimePicker(
                                        context: context,
                                        initialTime: toTime,
                                      );

                                      if (newTime == null) return;
                                      if (validateTimeOfDay(newTime)) {
                                        showSnackBar(context,
                                            "Please select a time between 6:00 AM to 7:00 PM");
                                        return;
                                      }

                                      setState(() {
                                        toTime = newTime;
                                        toTimeTextController.text =
                                            toTime.format(context);
                                      });
                                    },
                                    child: AppTextField(
                                      labelText: "To.",
                                      controller: toTimeTextController,
                                      hintText: '6:00 PM',
                                      isEnabled: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep == 2
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: AppText(text: "Select room privacy"),
                      content: Column(
                        children: [
                          RadioListTile(
                            title: AppText(text: "Public"),
                            value: StudyRoomStatus.public,
                            groupValue: studyRoomStatus,
                            onChanged: (value) {
                              setState(() {
                                studyRoomStatus = value!;
                              });
                            },
                          ),
                          RadioListTile(
                            title: AppText(text: "Private"),
                            value: StudyRoomStatus.private,
                            groupValue: studyRoomStatus,
                            onChanged: (value) {
                              setState(() {
                                studyRoomStatus = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : AppButton(
                                  wrapRow: true,
                                  height: 50,
                                  onPressed: () async {
                                    setState(() => _isLoading = true);
                                    await studyPoolService.createStudyPool(
                                      context: context,
                                      studyPoolName: studyNameController.text,
                                      status: studyRoomStatus,
                                      subject: selectedSubject,
                                      subTopics: selectedSubTopics,
                                      location: locationController.text,
                                      schedule: scheduleBuilder(
                                        selectedDate,
                                        fromTime,
                                        toTime,
                                      ),
                                    );
                                    setState(() => _isLoading = false);
                                    Navigator.of(context).pop();
                                  },
                                  text: "Create Study Room",
                                ),
                          TextButton(
                            onPressed: () => setState(() => _currentStep = 2),
                            child: AppText(
                              text: "<< Go back to previous step.",
                              textColor: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep == 3
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool validateStep() {
    switch (_currentStep) {
      case 0:
        return studyNameController.text.isNotEmpty &&
            locationController.text.isNotEmpty;
      case 2:
        return selectedDateTextController.text.isNotEmpty &&
            fromTimeTextController.text.isNotEmpty &&
            toTimeTextController.text.isNotEmpty;
      default:
        return true;
    }
  }

  bool validateTimeOfDay(TimeOfDay timeOfDay) {
    return timeOfDay.hour < 6 || timeOfDay.hour > 19;
  }

  bool validateDate(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  String scheduleBuilder(
    DateTime date,
    TimeOfDay from,
    TimeOfDay to,
  ) {
    var newDate = date.toIso8601String();
    var fromTime = '${from.hour}:${from.minute}';
    var toTime = '${to.hour}:${to.minute}';

    return "$newDate+$fromTime.$toTime";
  }

  void removeSubTopic(SubTopic subTopic) {
    setState(() {
      selectedSubTopics.remove(subTopic);
      availableSubTopics.add(
        DropdownMenuItem(
          value: subTopic,
          child: AppText(text: subTopic.topic),
        ),
      );
    });
  }

  void setSubTopics(String subjectCode) {
    availableSubTopics = userProvider.getSubTopics(subjectCode).map(
      (subTopic) {
        if (subTopic.topic == '' && subTopic.description == '') {
          return DropdownMenuItem(
            value: subTopic,
            child: AppText(text: 'List of subtopics'),
          );
        }
        return DropdownMenuItem(
          value: subTopic,
          child: AppText(text: subTopic.topic),
        );
      },
    ).toList();
  }

  void initialize() {
    userProvider = Provider.of<UserProvider>(context, listen: false);

    selectedSubject = userProvider.firstSubject;

    availableSubjects = userProvider.user.subjects
        .map(
          (subject) => DropdownMenuItem(
            value: subject,
            child:
                AppText(text: '${subject.subjectCode}: ${subject.description}'),
          ),
        )
        .toList();

    setSubTopics(selectedSubject.subjectCode);

    selectedSubTopic = availableSubTopics[0].value as SubTopic;
  }

  void _onChangeSubject(Subject? value) {
    setState(() {
      if (selectedSubject != value) {
        selectedSubTopics = [];
      }
      selectedSubject = value!;
      setSubTopics(value.subjectCode);
      selectedSubTopic = availableSubTopics[0].value as SubTopic;
    });
  }

  Future<void> _showSelectTopicDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, subSetState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: AppText(text: 'Select a topic.'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButton(
                                isExpanded: true,
                                menuMaxHeight: 300,
                                value: selectedSubTopic,
                                items: availableSubTopics,
                                onChanged: (subTopic) => subSetState(
                                  () => selectedSubTopic = subTopic!,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AppButton(
                  wrapRow: true,
                  height: 50,
                  isEnabled: isEmptySubtopic(selectedSubTopic) ? false : true,
                  onPressed: () {
                    subSetState(() {
                      selectedSubTopics.add(selectedSubTopic);
                      availableSubTopics.removeWhere(
                        (element) => element.value == selectedSubTopic,
                      );
                      selectedSubTopic =
                          availableSubTopics[0].value as SubTopic;
                    });

                    Navigator.of(context).pop();
                  },
                  text: "Add subtopic",
                ),
              ],
            ),
          ),
        );
      },
    );
    setState(() {});
  }

  tapped(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  continued() {
    _currentStep < 3
        ? validateStep()
            ? setState(() => _currentStep += 1)
            : ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: AppText(
                    text: 'Please fill up all fields.',
                    textColor: Colors.white,
                  ),
                ),
              )
        : Navigator.of(context).pop();
  }

  cancel() {
    _currentStep > 0
        ? setState(() => _currentStep -= 1)
        : Navigator.of(context).pop();
  }

  bool isEmptySubtopic(SubTopic subTopic) {
    return subTopic.topic == '' && subTopic.description == '';
  }
}
