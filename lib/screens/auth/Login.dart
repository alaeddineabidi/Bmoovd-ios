import 'package:bmoovd/screens/HomeScreen/HomeScreen.dart';
import 'package:bmoovd/screens/auth/Register.dart';
import 'package:bmoovd/screens/auth/forgotpass.dart';
import 'package:bmoovd/screens/staff/Home/staff_Home_Screen.dart';
import 'package:bmoovd/widgets/button.dart';
import 'package:bmoovd/widgets/cutomtextfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  // Variablen für Fehlermeldungen
  String? _emailError;
  String? _passwordError;

  void _login() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String userId = userCredential.user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        String role = userDoc.get('role');

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StaffHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        setState(() {
          _emailError = 'Benutzer nicht gefunden';
        });
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('email')) {
          _emailError = 'Ungültige E-Mail';
        } else if (e.toString().contains('password')) {
          _passwordError = 'Falsches Passwort';
        } else {
          _emailError = '';
        }
      });
    }
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    String userId = userCredential.user!.uid;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      String role = userDoc.get('role');

      if (role == 'admin') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => StaffHomePage()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
          (route) => false,
        );
      }
    } else {
      setState(() {
        _emailError = 'Benutzer nicht gefunden';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  "Anmeldung",
                  style: GoogleFonts.plusJakartaSans(
                    color: Color(0xffC4CFE1),
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                CustomTextField(
                  controller: _emailController,
                  labelText: 'E-Mail',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  borderColor: _emailError != null || _passwordError != null
                      ? Colors.red
                      : Colors.grey,
                ),
                SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Passwort',
                  obscureText: true,
                  errorText: _passwordError,
                  borderColor: _emailError != null || _passwordError != null
                      ? Colors.red
                      : Colors.grey,
                ),
                // Hinzufügen des "Passwort vergessen"-Links
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                       Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                    );
                    },
                    child: Text(
                      'Passwort vergessen?',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Button(
                  onPressed: _login,
                  text: 'Einloggen',
                  color: Color(0xFF007C7C),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    signInWithGoogle();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 2, color: Color(0xff18212E)),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/icons/google1.png"),
                          SizedBox(width: 10),
                          Text(
                            "Mit Google einloggen",
                            style: GoogleFonts.plusJakartaSans(
                              color: Color(0xffE6E7E9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  child: Text(
                    'Kein Konto? Registrieren',
                    style: GoogleFonts.poppins(
                      color: Color(0xFF007C7C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
