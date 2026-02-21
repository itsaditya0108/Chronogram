import 'package:flutter/material.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key, required this.mobile, required this.maskedEmail});
  final String mobile;
  final String maskedEmail;
  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Email Screen for ${widget.maskedEmail}')),
    );
  }
}