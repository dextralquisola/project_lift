import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project_lift/features/study_pool/widgets/study_card_widget.dart';
import 'package:project_lift/models/study_room.dart';

import '../../../widgets/app_text.dart';
import '../service/study_pool_service.dart';

class StudyRoomSearchScreen extends StatefulWidget {
  const StudyRoomSearchScreen({super.key});

  @override
  State<StudyRoomSearchScreen> createState() => _StudyRoomSearchScreenState();
}

class _StudyRoomSearchScreenState extends State<StudyRoomSearchScreen> {
  final studyPoolService = StudyPoolService();

  final _searchController = StreamController<String>();
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
            return FutureBuilder<List<StudyRoom>>(
              future: studyPoolService.searchStudyRoom(
                search: _textController.text,
                context: context,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // Display search results
                  final studyRoom = snapshot.data;
                  return ListView.builder(
                    itemCount: studyRoom!.length,
                    itemBuilder: (context, index) {
                      return StudyPoolCard(
                        studyRoom: studyRoom[index],
                      );
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
