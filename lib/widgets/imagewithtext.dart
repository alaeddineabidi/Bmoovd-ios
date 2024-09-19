import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageWithTextOverlay extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  ImageWithTextOverlay({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0), // Correction du borderRadius
          child: Container(
            height: 594,
            width: 500,
            child: Image.asset(
              imagePath,
              height: 594.281,
              fit: BoxFit.cover, // Assure que l'image couvre toute la zone
            ),
          ),
        ),
        Container(
          height: 594,
          width: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(32, 34, 43, 0.0), // Haut transparent
                Color.fromRGBO(26, 28, 32, 0.9), // Bas opaque
              ],
              stops: [0.6, 0.8], // La dégradation s'arrête au milieu
            ),
          ),
        ),

        Positioned(
          bottom: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.transparent,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: title + '\n',
                    style: GoogleFonts.plusJakartaSans(
                      color: Color(0xFFE6E7E9),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                       height: 18.773 / 12.8, // Hauteur de ligne relative
                       letterSpacing: -0.348,
                    ),
                  ),
                  TextSpan(
                    text: subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: Color(0xFFB3B3B3),
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
