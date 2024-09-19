import 'package:bmoovd/screens/auth/verificationPage.dart';
import 'package:bmoovd/widgets/button.dart';
import 'package:bmoovd/widgets/cutomtextfield.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void _signup() async {
    // Vérifier que le mot de passe contient au moins 8 caractères
    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Das Passwort muss mindestens 8 Zeichen lang sein.')),
      );
      return;
    }

    // Vérifier que le mot de passe et la confirmation sont identiques
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Die Passwörter stimmen nicht überein.')),
      );
      return;
    }

    try {
      // Créer un nouvel utilisateur avec l'email et le mot de passe
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Récupérer l'utilisateur nouvellement créé
      User? user = userCredential.user;
        String? fcmToken = await FirebaseMessaging.instance.getToken();


      if (user != null) {
        // Combiner le prénom et le nom en une seule chaîne
        String fullName = "${_firstNameController.text} ${_lastNameController.text}";

        await _firestore.collection('users').doc(user.uid).set({
          'email': _emailController.text,
          'name': fullName,
          'role': 'user',
          'points': 0,
          'fcmToken':fcmToken,
        });

        await user.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eine Bestätigungs-E-Mail wurde gesendet. Bitte überprüfen Sie Ihr Postfach.'),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerificationPendingScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler bei der Registrierung: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          height: 20,
          margin: EdgeInsets.all(8), // Marges à l'intérieur du container
          decoration: BoxDecoration(
            color:Color.fromRGBO(0, 124, 124, 0.60), // Couleur du container
            borderRadius: BorderRadius.circular(100), // Coins arrondis
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back,size: 20,), // Icône de flèche
            onPressed: () {
              Navigator.pop(context); // Retour à l'écran précédent
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text("Registrieren",style: GoogleFonts.plusJakartaSans(color:Color(0xffE6E7E9),fontSize: 30,fontWeight: FontWeight.w700),)
              ),
            ),
            SizedBox(height: 20),
            // Placer les champs de prénom et de nom dans une ligne
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _firstNameController,
                    labelText: 'Vorname',
                     // Prénom
                    keyboardType: TextInputType.name,
                  ),
                ),
                SizedBox(width: 10), // Espacement entre les champs
                Expanded(
                  child: CustomTextField(
                    controller: _lastNameController,
                    labelText: 'Nachname', // Nom
                    keyboardType: TextInputType.name,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: _emailController,
              labelText: 'E-Mail',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Passwort',
              obscureText: true,
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: 'Passwort bestätigen',
              obscureText: true,
            ),
            SizedBox(height: 20),
            Button(
              onPressed: _signup,
              text: 'Benutzerkonto erstellen',
              color: Color(0xFF007C7C),
            ),
            SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }
}
