import 'package:flutter/material.dart';
import 'package:project_lift/widgets/app_button.dart';

import '../models/user.dart';
import '../services/global_services.dart';
import './app_text.dart';

class ReportUserScreen extends StatefulWidget {
  final User? user;
  final Map<String, dynamic>? userParticipant;
  const ReportUserScreen({
    super.key,
    this.user,
    this.userParticipant,
  });

  @override
  State<ReportUserScreen> createState() => _ReportUserScreenState();
}

class _ReportUserScreenState extends State<ReportUserScreen> {
  final globalService = GlobalService();
  final _textField = TextEditingController();

  var chipValues = List.generate(
    4,
    (index) => false,
  );

  var _selectedChip = -1;

  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Report User'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              AppText(
                text: widget.user != null
                    ? "Report ${widget.user!.firstName} ${widget.user!.lastName}"
                    : "Report ${widget.userParticipant!['firstName']} ${widget.userParticipant!['lastName']}",
                textSize: 20,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chipBuilder("Spam", 0),
                  _chipBuilder("Harassment", 1),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chipBuilder("Inappropriate content", 2),
                  _chipBuilder("Other", 3),
                ],
              ),
              const SizedBox(height: 20),
              AppText(
                text: "Additional Details",
                textSize: 20,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 20),
              TextField(
                maxLines: 5,
                controller: _textField,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Type here...",
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : AppButton(
                      height: 50,
                      wrapRow: true,
                      onPressed: () async {
                        if (_selectedChip == -1 || _textField.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Please select a category or add details"),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });
                        await globalService.reportUser(
                          context: context,
                          userId: widget.user != null
                              ? widget.user!.userId
                              : widget.userParticipant!['userId'],
                          category: _reportStringBuilder(_selectedChip),
                          content: _textField.text,
                        );
                        setState(() {
                          _isLoading = false;
                        });

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      text: "Report",
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipBuilder(String text, int index) {
    return ChoiceChip(
      selectedColor: Colors.redAccent,
      selected: chipValues[index],
      onSelected: (value) {
        setState(() {
          if (chipValues[index]) {
            chipValues[index] = false;
            _selectedChip = -1;
            return;
          }

          chipValues[index] = value;
          _selectedChip = index;
          for (var i = 0; i < chipValues.length; i++) {
            if (i != index) {
              chipValues[i] = false;
            }
          }
        });
      },
      label: AppText(
        text: text,
        textColor: chipValues[index] ? Colors.white : Colors.black,
      ),
    );
  }

  String _reportStringBuilder(int index) {
    switch (index) {
      case 0:
        return "spam";
      case 1:
        return "harassment";
      case 2:
        return "inappropriate content";
      case 3:
        return "other";
      default:
        return "";
    }
  }
}
