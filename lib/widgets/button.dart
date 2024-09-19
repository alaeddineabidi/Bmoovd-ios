import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  Button({required this.text, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width, // Largeur de l'écran
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color, // Utilisation de la couleur passée en paramètre
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0), // Coins légèrement arrondis
            ),
            padding: EdgeInsets.symmetric(vertical: 16.0), // Ajustement de la hauteur du bouton
          ),
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
