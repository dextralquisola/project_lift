import 'package:flutter/material.dart';
import 'package:project_lift/features/study_pool/service/study_pool_service.dart';
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
  var studyRoomStatus = StudyRoomStatus.public;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Study Room'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(
              controller: studyNameController,
              labelText: "Study Room Name",
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(text: "Select subject", textSize: 20),
                          DropdownButton(
                            isExpanded: true,
                            menuMaxHeight: 300,
                            value: selectedSubject,
                            items: availableSubjects,
                            onChanged: (s) => _onChangeSubject(s as Subject),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AppText(text: "Selected subtopics", textSize: 20),
                        const Spacer(),
                        IconButton(
                          onPressed: () async =>
                              await _showSelectTopicDialog(context),
                          icon: Icon(Icons.add, color: primaryColor),
                        ),
                      ],
                    ),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: selectedSubTopics.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: AppText(text: selectedSubTopics[index].topic),
                          trailing: IconButton(
                            onPressed: () =>
                                removeSubTopic(selectedSubTopics[index]),
                            icon: const Icon(Icons.remove, color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                      );
                      setState(() => _isLoading = false);
                      Navigator.of(context).pop();
                    },
                    text: "Create Study Room",
                  ),
          ],
        ),
      ),
    );
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

  bool isEmptySubtopic(SubTopic subTopic) {
    return subTopic.topic == '' && subTopic.description == '';
  }
}
