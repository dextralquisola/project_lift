import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../service/study_pool_service.dart';
import '../../../constants/styles.dart';
import '../../../providers/current_room_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';
import '../../../widgets/app_textfield.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final studyroomService = StudyPoolService();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentStudyRoom = Provider.of<CurrentStudyRoomProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda for this session'),
      ),
      resizeToAvoidBottomInset: false,
      body: currentStudyRoom.todos.isEmpty
          ? const Center(
              child: AppText(
                text: 'No agenda yet',
                textColor: Colors.grey,
              ),
            )
          : ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 5),
              itemCount: currentStudyRoom.todos.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: AppText(
                      text:
                          "${index + 1}.) ${currentStudyRoom.todos[index].title}",
                      fontWeight: FontWeight.bold,
                    ),
                    subtitle: AppText(
                      text: currentStudyRoom.todos[index].description,
                    ),
                    trailing: userProvider.user.userId ==
                            currentStudyRoom.studyRoom.roomOwner
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showAddTodoDialog(context, index);
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: primaryColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _showDeleteWarning(
                                      context, index, currentStudyRoom);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
      floatingActionButton:
          userProvider.user.userId == currentStudyRoom.studyRoom.roomOwner
              ? FloatingActionButton(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    _showAddTodoDialog(context);
                  },
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }

  void _showDeleteWarning(
    BuildContext context,
    int index,
    CurrentStudyRoomProvider currentStudyRoom,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const AppText(
            text: 'Delete agenda?',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppText(
                text: 'Are you sure you want to delete this agenda?',
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const AppText(
                      text: 'Cancel',
                      textColor: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await studyroomService.deleteTodo(
                          context: context,
                          roomId: currentStudyRoom.studyRoom.roomId,
                          todoId: currentStudyRoom.todos[index].id,
                        );
                        setState(() {
                          _isLoading = false;
                        });
                        if (mounted) Navigator.of(context).pop();
                      },
                      child: const AppText(
                        text: 'Delete',
                        textColor: Colors.red,
                      )),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _showAddTodoDialog(BuildContext context, [int? index]) {
    final currentStudyRoom =
        Provider.of<CurrentStudyRoomProvider>(context, listen: false);
    if (index != null) {
      titleController.text = currentStudyRoom.todos[index].title;
      descriptionController.text = currentStudyRoom.todos[index].description;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, st) => SingleChildScrollView(
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: AppText(
                text: index != null ? 'Edit agenda.' : 'Add an agenda.',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: titleController,
                    labelText: 'Title',
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: descriptionController,
                    maxLines: 3,
                    labelText: 'Description',
                  ),
                  const SizedBox(height: 10),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : AppButton(
                          wrapRow: true,
                          height: 40,
                          onPressed: index != null
                              ? () async {
                                  st(() {
                                    _isLoading = true;
                                  });
                                  var updatedTodo =
                                      currentStudyRoom.todos[index].copyWith(
                                    title: titleController.text,
                                    description: descriptionController.text,
                                  );
                                  await studyroomService.updateTodo(
                                    context: context,
                                    roomId: currentStudyRoom.studyRoom.roomId,
                                    todo: updatedTodo,
                                  );
                                  st(() {
                                    _isLoading = false;
                                  });
                                  if (mounted) Navigator.of(context).pop();
                                }
                              : () async {
                                  st(() {
                                    _isLoading = true;
                                  });
                                  await studyroomService.addTodo(
                                    context: context,
                                    title: titleController.text,
                                    description: descriptionController.text,
                                  );
                                  st(() {
                                    _isLoading = false;
                                  });
                                  if (mounted) Navigator.of(context).pop();
                                },
                          text: index != null ? 'Update' : 'Add +',
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
