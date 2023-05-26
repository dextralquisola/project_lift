import 'package:flutter/material.dart';

class ViewTutorScreen extends StatefulWidget {
  const ViewTutorScreen({super.key});

  @override
  State<ViewTutorScreen> createState() => _ViewTutorScreenState();
}

class _ViewTutorScreenState extends State<ViewTutorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Tutor'),
      ),
      body: Center(
        child: Text('View Tutor'),
      ),
    );
  }
}
