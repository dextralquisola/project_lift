import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/study_card_widget.dart';
import '../../../models/study_room.dart';
import '../../../providers/study_room_providers.dart';
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
  final _textController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.stream.listen((searchQuery) async {
      await Future.delayed(const Duration(seconds: 3));
      if (searchQuery == _searchQuery) {
        setState(() {
          _searchQuery = searchQuery;
        });
      }
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
    final studyRoomProvider =
        Provider.of<StudyRoomProvider>(context, listen: false);
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
              onChanged: (searchQuery) {
                _searchQuery = searchQuery;
                _searchController.add(searchQuery);
              },
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchQuery = '';
                      _textController.clear();
                    },
                  ),
                  hintText: 'Search...',
                  border: InputBorder.none),
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? Center(
              child: AppText(
                text: "Search something...",
              ),
            )
          : FutureBuilder<List<StudyRoom>>(
              future: studyPoolService.searchStudyRoom(
                search: _searchQuery,
                context: context,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasData) {
                  // Display search results
                  final studyRoom = snapshot.data;
                  return ListView.builder(
                    itemCount: studyRoom!.length,
                    itemBuilder: (context, index) {
                      return StudyPoolCard(
                        studyRoom: studyRoom[index],
                        isStudyRoomPending: studyRoomProvider.isRoomPending(
                          studyRoom[index].roomId,
                        ),
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
            ),
    );
  }
}
