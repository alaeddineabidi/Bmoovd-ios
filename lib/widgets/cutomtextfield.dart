import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final Color borderColor;

  CustomTextField({
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.borderColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Radius for rounded corners
          borderSide: BorderSide(color: borderColor, width: 1.0), // Border color and width
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Radius for rounded corners
          borderSide: BorderSide(color: borderColor, width: 1.0), // Border color and width
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Radius for rounded corners
          borderSide: BorderSide(color: borderColor, width: 2.0), // Border color and width when focused
        ),
        errorText: errorText, // Display error text
        errorStyle: GoogleFonts.plusJakartaSans(color: Colors.red), // Error text style
      ),
    );
  }
}
