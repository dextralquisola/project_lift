import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_requests_provider.dart';
import '../widgets/tutor_card_widget.dart';
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
    final userRequestsProvider =
        Provider.of<UserRequestsProvider>(context, listen: false);
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
                    _textController.clear();
                  },
                ),
                hintText: 'Search...',
                border: InputBorder.none,
              ),
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
          : FutureBuilder<List<User>>(
              future: tutorService.searchTutor(
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
                  final tutors = snapshot.data;
                  return ListView.builder(
                    itemCount: tutors!.length,
                    itemBuilder: (context, index) {
                      final tutor = tutors[index];
                      var isPendingRequest =
                          userRequestsProvider.isHasRequest(tutor.userId);
                      return TutorCard(
                        tutor: tutor,
                        isPendingRequest: isPendingRequest,
                        isEnabled: true,
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
