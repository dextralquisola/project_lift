import 'package:flutter/material.dart';

import '../../../constants/styles.dart';

class PendingTuteesScreen extends StatefulWidget {
  const PendingTuteesScreen({super.key});

  @override
  State<PendingTuteesScreen> createState() => _PendingTuteesScreenState();
}

class _PendingTuteesScreenState extends State<PendingTuteesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Tutee Requests'),
        backgroundColor: primaryColor,
      ),
      body: const Center(
        child: Text('Pending Tutees Screen'),
      ),
    );
  }
}