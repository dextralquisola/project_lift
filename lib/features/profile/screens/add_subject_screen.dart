import 'package:flutter/material.dart';
import 'package:project_lift/constants/styles.dart';
import 'package:project_lift/features/profile/service/profile_service.dart';
import 'package:project_lift/models/subject.dart';
import 'package:project_lift/utils/utils.dart';
import 'package:project_lift/widgets/app_button.dart';
import 'package:project_lift/widgets/app_text.dart';
import 'package:project_lift/widgets/app_textfield.dart';
import 'package:provider/provider.dart';

import '../../../constants/subjects.dart';
import '../../../providers/user_provider.dart';

class AddSubjectScreen extends StatefulWidget {
  final Subject? subject;
  const AddSubjectScreen({
    super.key,
    this.subject,
  });

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final topicController = TextEditingController();
  final descriptionController = TextEditingController();

  List<SubTopic> subTopics = [];

  String selectedValue = computerScience[0]['subjectCode']!;

  late List<DropdownMenuItem<String>> dropdownItems;

  final profileService = ProfileService();

  var _isEnabled = true;
  var _isLoadingAddUpdate = false;
  var _isLoadingDelete = false;

  @override
  void dispose() {
    super.dispose();
    topicController.dispose();
    descriptionController.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedValue =
        widget.subject?.subjectCode ?? computerScience[0]['subjectCode']!;
    subTopics = widget.subject?.subTopics ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    var filteredSubjects = filterSubjects(userProvider);
    dropdownItems = widget.subject != null
        ? [
            DropdownMenuItem(
              value: widget.subject!.subjectCode,
              child: AppText(
                  text:
                      '${widget.subject!.subjectCode}: ${widget.subject!.description}'),
            )
          ]
        : filteredSubjects
            .map(
              (e) => DropdownMenuItem(
                value: e['subjectCode'],
                child: e['subjectCode'] != ''
                    ? AppText(text: '${e['subjectCode']}: ${e['description']}')
                    : AppText(text: 'List of subjects'),
              ),
            )
            .toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: widget.subject != null
            ? const Text("Update subject")
            : const Text('Add Subject'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                          AppText(
                              text: widget.subject != null
                                  ? "Update Subject"
                                  : "Select subject",
                              textSize: 20),
                          DropdownButton(
                            isExpanded: true,
                            menuMaxHeight: 300,
                            value: selectedValue,
                            items: dropdownItems,
                            onChanged:
                                widget.subject != null ? null : _onChange,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(text: "Add sub topics", textSize: 20),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    if (selectedValue == "") {
                                      showSnackBar(
                                          context, "Please select a subject.");
                                      return;
                                    }
                                    _showAddTopicDialog(context);
                                  },
                                  child: AppText(
                                    text: "Add +",
                                    textSize: 15,
                                    textColor: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ListView.builder(
                            itemBuilder: (context, index) {
                              return Card(
                                child: ListTile(
                                  title: AppText(
                                    text: subTopics[index].topic,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  subtitle: AppText(
                                      text: subTopics[index].description),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _showAddTopicDialog(context, index);
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.green,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            subTopics.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            itemCount: subTopics.length,
                            shrinkWrap: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          _isLoadingAddUpdate
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : AppButton(
                                  isEnabled: _isEnabled,
                                  onPressed: () async {
                                    if (subTopics.isNotEmpty &&
                                        selectedValue != '') {
                                      var newSubject = Subject(
                                        subjectCode: selectedValue,
                                        description: computerScience.firstWhere(
                                            (element) =>
                                                element['subjectCode'] ==
                                                selectedValue)['description']!,
                                        subTopics: subTopics,
                                      );

                                      setState(() {
                                        _isLoadingAddUpdate = true;
                                      });

                                      if (widget.subject != null) {
                                        await profileService.updateSubject(
                                          subject: newSubject,
                                          context: context,
                                        );
                                      } else {
                                        await profileService.addSubject(
                                          subject: newSubject,
                                          context: context,
                                        );
                                      }

                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: AppText(
                                            text:
                                                'Please add sub topics and select a subject.',
                                            textColor: Colors.white,
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  },
                                  wrapRow: true,
                                  height: 50,
                                  text: widget.subject != null
                                      ? "Update subject"
                                      : "Add subject",
                                ),
                          if (widget.subject != null)
                            _isLoadingDelete
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: AppButton(
                                      onPressed: () async {
                                        setState(() {
                                          _isEnabled = false;
                                          _isLoadingDelete = true;
                                        });
                                        await profileService.deleteSubject(
                                          context: context,
                                          subject: widget.subject!,
                                        );
                                        setState(() {
                                          _isLoadingDelete = true;
                                        });
                                        Navigator.pop(context);
                                      },
                                      text: "Delete subject",
                                      bgColor: Colors.redAccent,
                                      wrapRow: true,
                                      height: 50,
                                    ),
                                  ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> filterSubjects(UserProvider userProvider) {
    List<Map<String, String>> newFilteredSubjects = [];

    for (var subject in computerScience) {
      if (!userProvider.user.isSubjectAdded(subject['subjectCode']!)) {
        newFilteredSubjects.add(subject);
      }
    }

    return newFilteredSubjects;
  }

  void _onChange(String? value) {
    setState(() {
      selectedValue = value!;
      subTopics = [];
    });
  }

  void _showAddTopicDialog(BuildContext context, [int? index]) {
    if (index != null) {
      topicController.text = subTopics[index].topic;
      descriptionController.text = subTopics[index].description;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: AppText(
            text: index != null ? 'Edit a topic.' : 'Add a topic.',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: topicController,
                labelText: 'Topic name',
                hintText: 'Loopings',
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: descriptionController,
                labelText: 'Description',
                hintText: 'For loop, while loop, do while loop',
              ),
              const SizedBox(height: 10),
              AppButton(
                wrapRow: true,
                height: 40,
                onPressed: index != null
                    ? () {
                        setState(
                          () {
                            subTopics[index] = subTopics[index].copyWith(
                                topic: topicController.text,
                                description: descriptionController.text);
                          },
                        );
                        topicController.clear();
                        descriptionController.clear();
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.pop(context);
                      }
                    : () {
                        setState(() {
                          subTopics.add(
                            SubTopic(
                              topic: topicController.text,
                              description: descriptionController.text,
                            ),
                          );
                        });
                        topicController.clear();
                        descriptionController.clear();
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.pop(context);
                      },
                text: index != null ? 'Update' : 'Add',
              ),
            ],
          ),
        );
      },
    );
  }
}
