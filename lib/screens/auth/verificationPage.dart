import 'package:bmoovd/screens/auth/Login.dart';
import 'package:bmoovd/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationPendingScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Mail-Bestätigung',style: GoogleFonts.poppins(fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Eine Bestätigungs-E-Mail wurde gesendet. Bitte überprüfen Sie Ihren Posteingang.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Button(
              onPressed: () async {
                // Abmelden und Rückkehr zur Anmeldeseite
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              text: 'Zurück zur Anmeldung', color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}
