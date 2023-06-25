import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/find_tutor_search_screen.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 16.0),
          child: SizedBox(
            height: 36.0,
            width: double.infinity,
            child: CupertinoTextField(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FindTutorSearchScreen(),
                  ),
                );
              },
              readOnly: true,
              keyboardType: TextInputType.text,
              placeholder: 'Search for a tutor',
              placeholderStyle: const TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
                fontFamily: 'Brutal',
              ),
              prefix: const Padding(
                padding: EdgeInsets.fromLTRB(9.0, 6.0, 9.0, 6.0),
                child: Icon(
                  Icons.search,
                  color: Colors.black54,
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
