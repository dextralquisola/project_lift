import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_lift/features/find_tutor/widgets/tutor_card_widget.dart';
import 'package:project_lift/widgets/app_textfield.dart';

import '../../../models/user.dart';
import '../../../widgets/app_text.dart';
import '../service/tutor_service.dart';

class FindTutorSearchScreen extends StatefulWidget {
  const FindTutorSearchScreen({super.key});

  @override
  State<FindTutorSearchScreen> createState() => _FindTutorSearchScreenState();
}

class _FindTutorSearchScreenState extends State<FindTutorSearchScreen> {
  final tutorService = TutorService();

  final _searchController = StreamController<String>();
  //final _debounce = const Duration(milliseconds: 300);
  Stream<String> get searchStream => _searchController.stream;

  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      _searchController.sink.add(_textController.text);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.close();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The search area here
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _textController.clear();
                    },
                  ),
                  hintText: 'Search...',
                  border: InputBorder.none),
            ),
          ),
        ),
      ),
      body: StreamBuilder<String>(
        stream: searchStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder<List<User>>(
              future: tutorService.searchTutor(
                search: _textController.text,
                context: context,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // Display search results
                  final tutors = snapshot.data;
                  return ListView.builder(
                    itemCount: tutors!.length,
                    itemBuilder: (context, index) {
                      final tutor = tutors[index];
                      return TutorCard(tutor: tutor);
                    },
                  );
                } else if (snapshot.hasError) {
                  // Display error message
                  print(snapshot.data);
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          } else {
            // Display empty search UI
          }
          return Center(
            child: AppText(
              text: "Empty search",
            ),
          );
        },
      ),
    );
  }
}
