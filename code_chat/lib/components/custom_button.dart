import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: Colors.white,
      ),
      child: isLoading
          ? CircularProgressIndicator(color: Color(0xFF6C5CE7))
          : Text(
        text,
        style: TextStyle(
          fontSize: 18,
          color: Color(0xFF6C5CE7),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}