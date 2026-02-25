import 'package:flutter/material.dart';

class EditLoginMobileDialog extends StatelessWidget {
  const EditLoginMobileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff1C1C1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        "Change Number?",
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        "Do you want to change login mobile number?",
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // close dialog
            Navigator.pop(context); // go back to login screen
          },
          child: const Text(
            "Yes Change",
            style: TextStyle(color: Colors.orange),
          ),
        ),
      ],
    );
  }
}