import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isEnabled;

  const AppButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0XFFD97706),
          disabledBackgroundColor: Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),

        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
