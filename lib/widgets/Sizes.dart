import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Sizes extends StatelessWidget {
  final String text;
   final bool isSelected;
  final Color color; 

  Sizes({required this.text, this.isSelected = false, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
         border: Border.all(
          color: isSelected ? Color.fromARGB(153, 0, 124, 124): Color.fromRGBO(230, 231, 233, 0.50),
          width: 2.0,
        ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              color: Color(0xFFE6E7E9),
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
