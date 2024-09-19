import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _resetPassword() async {
    setState(() {
      _emailError = null;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17.067),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17.067),
                border: Border.all(
                  color: const Color.fromRGBO(230, 231, 233, 0.60),
                  width: 0.853,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(49, 58, 91, 0.00),
                    Color(0xFF21273D),
                  ],
                ),
                boxShadow: [
                  const BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.30),
                    offset: Offset(0, 8.533),
                    blurRadius: 17.067,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligne les éléments avec de l'espace entre eux
                  children: [
                    const Spacer(), // Utilisé pour pousser l'icône à droite
                    InkWell(
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xffE6E7E9),
                      ),
                    ),
                  ],
                ),

                  const SizedBox(height: 30,),
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100),color: const Color(0xff007C7C)),
                    child:const Icon(Icons.check,size: 40,)
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Erfolg',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xffE6E7E9), fontSize: 18,fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 30),
                   Center(
                     child: Text(
                        'Eine E-Mail zum Zurücksetzen des Passworts wurde an ${_emailController.text.trim()} gesendet. Bitte überprüfe dein Postfach.',
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xffE6E7E9),fontSize: 14,fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                   ),
                  
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        _emailError = 'Ein Fehler ist aufgetreten. Bitte überprüfe deine E-Mail.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Passwort zurücksetzen",
              style: GoogleFonts.plusJakartaSans(
                color: Color(0xffC4CFE1),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-Mail',
                errorText: _emailError,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _resetPassword,
                child: Text('E-Mail zum Zurücksetzen senden', 
                  style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF007C7C)),
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
