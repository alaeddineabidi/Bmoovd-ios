import 'dart:io';

import 'package:bmoovd/screens/HomeScreen/HomeScreen.dart';
import 'package:bmoovd/screens/auth/Login.dart';
import 'package:bmoovd/screens/auth/Register.dart';
import 'package:bmoovd/screens/staff/Home/staff_Home_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroPage extends StatefulWidget {
  final String buttonClicked;

  IntroPage({required this.buttonClicked});

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  Future<void> signInWithGoogle() async {
   

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
          MaterialPageRoute(builder: (context) => StaffHomePage()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Benutzer nicht gefunden')),
      );
    }
  }

  void _nextPage() {
    if (currentPage < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: [
              buildIntroPage(
                title: 'Bienvenue!',
                description: 'Découvrez notre application.',
              ),
              buildIntroPage1(
                title: 'Fonctionnalités',
                description: 'Accédez à des fonctionnalités incroyables.',
              ),
              buildIntroPage2(
                title: 'Prêt à commencer?',
                description: 'Créez un compte ou connectez-vous.',
              ),
            ],
          ),
          Positioned(
            bottom: Platform.isIOS ? 10 : 5,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController, // Contrôle le PageView
                count: 3, // Le nombre de pages
                effect: WormEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  activeDotColor: Colors.white,
                  dotColor: Colors.grey,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: Platform.isIOS ? 10 : 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentPage > 0)
                    InkWell(
                      onTap: _previousPage,
                      child: Row(
                        children: [
                          Image.asset("assets/icons/precedent.png"),
                          Text(
                            "vorherige",
                            style: GoogleFonts.plusJakartaSans(
                              color: Color(0xffE6E7E9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (currentPage < 2)
                    InkWell(
                      onTap: _nextPage,
                      child: Row(
                        children: [
                          Text(
                            "Nächste",
                            style: GoogleFonts.plusJakartaSans(
                              color: Color(0xffE6E7E9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Image.asset("assets/icons/next.png"),
                        ],
                      ),
                    ),
                  // Ajout du bouton basé sur la variable buttonClicked
                  // ignore: unnecessary_null_comparison
                  if (widget.buttonClicked != null && currentPage == 2) // Cacher le bouton sur la dernière page
                    InkWell(
                      onTap: () {
                       if (widget.buttonClicked=="LoginPage"){
                         Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                       }else if(widget.buttonClicked=="HomeScreen"){
                         Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                            );
                       }else if (widget.buttonClicked=="Signup"){
                        Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupPage()),
                            );
                       }else {
                          signInWithGoogle();
                       }
                      },
                      
                      child: Row(
                        children: [
                          Text(
                            widget.buttonClicked == "LoginPage" ? "Login" : widget.buttonClicked == "HomeScreen" ? "home":widget.buttonClicked == "Signup" ?"Signup":widget.buttonClicked=="Google"?"Login":widget.buttonClicked,
                            style: GoogleFonts.plusJakartaSans(
                              color: Color(0xffE6E7E9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Image.asset("assets/icons/next.png"),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour créer chaque page d'introduction
  Widget buildIntroPage({required String title, required String description}) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20, top: 10, bottom: 8),
            child: Text(
              "Datenschutz\n&\nNutzungsbedingungen",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold, // Titre en gras
                color: Color(0xffE6E7E9),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Bevor Sie beginnen, lesen und akzeptieren Sie bitte das Folgende.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Color(0xffB3B3B3),
              fontWeight: FontWeight.bold, // Sous-titre en gras
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),

          // Ajout d'un container scrollable pour le texte long
          Expanded( // Utiliser Expanded pour que le texte puisse défiler
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff22242A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '''Datenschutzerklärung für die App 'Bmoovd'
Diese Datenschutzerklärung klärt Sie über die Art, den Umfang und den Zweck der Verarbeitung von personenbezogenen Daten (nachfolgend „Daten“) innerhalb unserer App „Bmoovd“ auf.

Verantwortlicher für die Datenverarbeitung im Sinne der Datenschutz-Grundverordnung (DSGVO) ist:

**Verantwortlicher:**
Firma Röhrdanz Fun + Fitness GmbH
Vertreten durch die Geschäftsführer Holger Locke, Dirk Winter
Wolfsburger Landstr. 6B
38442 Wolfsburg
Eingetragen im Handelsregister des Amtsgerichts Braunschweig unter der HRB 206 446
USt.-IdNr.: DE 311194045
Telefon: 05362 – 503 100-0
Fax: 05362 – 503 100-50
E-Mail: info@bmoovd.de
www.bmoovd.de

**1. Erhobene Daten**
Wir erheben und verarbeiten die folgenden personenbezogenen Daten:
- Persönliche Identifikationsdaten: Name, E-Mail-Adresse, Telefonnummer, Anschrift.
- Zahlungsinformationen: Kreditkarteninformationen, Bankverbindungen, PayPal-Daten.
- Nutzungsdaten: Informationen darüber, wie Sie die App nutzen, z. B. Ihre Interaktionen mit Funktionen wie Tippspiel, Bestellungen, Chatbot, Galerie, Support, Shop und Bezahlung.
- Technische Daten: IP-Adresse, Gerätetyp, Betriebssystem, eindeutige Gerätekennungen, App-Version.
- Kommunikationsdaten: Inhalte Ihrer Anfragen und Interaktionen über unseren Support oder Chatbot.

**2. Zweck der Datenverarbeitung**
Die erhobenen Daten werden zu folgenden Zwecken verarbeitet:
- Erbringung und Verbesserung unserer Dienstleistungen: Bereitstellung der Funktionen der App, einschließlich Tippspiel, Bestellungen, Shop, Bezahlung, Galerie und Kundenservice.
- Bestellabwicklung und Zahlungsverkehr: Verwaltung und Abwicklung von Bestellungen und Zahlungen.
- Kundenservice: Bearbeitung von Support-Anfragen und Bereitstellung von Hilfeleistungen.
- Personalisierung: Anpassung der App-Erfahrung und Marketingaktivitäten, sofern Sie zugestimmt haben.
- Sicherheit: Gewährleistung der Sicherheit und Integrität unserer App und der gespeicherten Daten.

**3. Weitergabe von Daten**
Wir geben Ihre Daten nur unter bestimmten Bedingungen an Dritte weiter:
- An Dienstleister, die uns bei der Erbringung unserer Dienstleistungen unterstützen.
- An Zahlungsdienstleister, um Zahlungen zu verarbeiten.
- An Behörden oder rechtliche Stellen, wenn wir gesetzlich dazu verpflichtet sind.

**4. Ihre Rechte**
Als betroffene Person haben Sie folgende Rechte:
- Auskunftsrecht: Sie haben das Recht, Auskunft über die von uns verarbeiteten personenbezogenen Daten zu verlangen.
- Berichtigungsrecht: Sie können die Berichtigung unrichtiger oder unvollständiger Daten verlangen.
- Löschungsrecht: Sie können unter bestimmten Voraussetzungen die Löschung Ihrer personenbezogenen Daten verlangen.
- Widerspruchsrecht: Sie können der Verarbeitung Ihrer personenbezogenen Daten widersprechen, sofern die Datenverarbeitung auf berechtigten Interessen basiert.

**5. Datensicherheit**
Wir setzen technische und organisatorische Maßnahmen ein, um Ihre Daten vor unberechtigtem Zugriff, Verlust oder Missbrauch zu schützen. Unsere Sicherheitsmaßnahmen werden regelmäßig überprüft und angepasst.

**6. Änderungen dieser Datenschutzerklärung**
Wir behalten uns vor, diese Datenschutzerklärung bei Bedarf anzupassen, um Änderungen unserer App oder rechtliche Anforderungen zu berücksichtigen. Die jeweils aktuelle Fassung finden Sie in der App.

**Kontakt**
Bei Fragen zur Verarbeitung Ihrer Daten oder zur Ausübung Ihrer Rechte können Sie sich an unseren Datenschutzbeauftragten wenden:

Datenschutzbeauftragter:
Rechtsanwalt Jan-Henrik Nolte
E-Mail: datenschutz@bmoovd.de

Stand: August 2024''', // Texte long
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Color(0xffB3B3B3),
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }





  Widget buildIntroPage1({required String title, required String description}) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20, top: 10, bottom: 8),
            child: Text(
              "Tutorial",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 30,
                fontWeight: FontWeight.w700, // Titre en gras
                color: Color(0xffE6E7E9),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 2,
                  color: Colors.white,
                  endIndent: 10, // Espace entre la ligne et le texte
                ),
              ),
              Text(
                "Home",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffE6E7E9),
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 2,
                  color: Colors.white,
                  indent: 10, // Espace entre le texte et la ligne
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "Herzlich willkommen! Wir starten mit einem kurzen funktionsüberblick",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Color(0xffB3B3B3),
              fontWeight: FontWeight.bold, // Sous-titre en gras
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),

          // Utilisation de MediaQuery pour ajuster la taille de l'image
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/TutoHome.png",
                fit: BoxFit.contain, // Ajuste la taille de l'image pour qu'elle soit visible sans déborder
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIntroPage2({required String title, required String description}) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20, top: 10, bottom: 8),
            child: Text(
              "Tutorial",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 30,
                fontWeight: FontWeight.w700, // Titre en gras
                color: Color(0xffE6E7E9),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 2,
                  color: Colors.white,
                  endIndent: 10, // Espace entre la ligne et le texte
                ),
              ),
              Text(
                "Spiel",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffE6E7E9),
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 2,
                  color: Colors.white,
                  indent: 10, // Espace entre le texte et la ligne
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "Herzlich willkommen! Wir starten mit einem kurzen funktionsüberblick",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Color(0xffB3B3B3),
              fontWeight: FontWeight.bold, // Sous-titre en gras
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),

          // Utilisation de MediaQuery pour ajuster la taille de l'image
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/TutoSpiel.png",
                fit: BoxFit.contain, // Ajuste la taille de l'image pour qu'elle soit visible sans déborder
              ),
            ),
          ),
        ],
      ),
    );
  }
}
