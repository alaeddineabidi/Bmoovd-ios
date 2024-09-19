import 'package:bmoovd/screens/auth/Login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DialogHelper {
  // Méthode statique pour montrer le dialog
  static void showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFf9b334),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Image.asset(
                'assets/logo/bmoovd_wortmarke_subline_wht.png',
                height: 40,
              ),
              const SizedBox(width: 10),
              Text(
                'Authentifizierung erforderlich.',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          content: Text(
            'Bitte melden Sie sich an, um auf diesen Bereich zuzugreifen.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Abbrechen',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                'Anmelden',
                style: GoogleFonts.poppins(color: Colors.teal),
              ),
            ),
          ],
        );
      },
    );
  }
}
