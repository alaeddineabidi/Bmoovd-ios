// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'dart:async';
import 'package:bmoovd/screens/BowlingBuchen/bowling_buchen_web_container.dart';
import 'package:bmoovd/screens/FoodScanQrCode/foodScanQrCode.dart';
import 'package:bmoovd/screens/LiveScoreScreens/LiveScores.dart';
import 'package:bmoovd/screens/auth/Login.dart';
import 'package:bmoovd/screens/gallery/post_photos.dart';
import 'package:bmoovd/screens/notifications/notifications.dart';
import 'package:bmoovd/screens/tisch_buchen/tisch_buchen.dart';
import 'package:bmoovd/widgets/BottomNavigationBar.dart';
import 'package:bmoovd/widgets/customButton.dart';
import 'package:bmoovd/widgets/imagewithtext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  late Timer _timer;
   User? user;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    user = FirebaseAuth.instance.currentUser;
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page!.toInt() + 1) % 8; // 8 est le nombre total d'images
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
   void _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      user = null; // Update the user state to null after logout
    });
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset("assets/logo/bmoovd_wortmarke_subline_wht.png", height: 70),
        actions: [
          IconButton(
  icon: user != null
      ? Image.asset(
          'assets/icons/Bell.png',  
          width: 24,
          height: 24,
        )
      : Image.asset(
          'assets/icons/login.png',  
          width: 24,
          height: 24,
        ),
  onPressed: () {
    if (user != null) {
       Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InvitationsPage()),
      );
    } else {
     Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
      },
    ), 
        
        ],
      ),
      body: Stack(
        children: [
          ListView(
            shrinkWrap: true,
            
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Tisch\nBuchen',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => WebViewContainerTischBuchen()),
                                );
                              },
                              color: const Color.fromARGB(255, 56, 54, 54),
                              assetImage: "assets/images/TischBuchen.png",
                              startColor: Color.fromRGBO(49, 58, 91, 0.10), // Couleur de début du dégradé
                              endColor: Color(0xFF21273D), // Couleur de fin du dégradé
                            ),

                          ),
                          Expanded(
                            child: CustomButton(
                              text: 'Bowling\nBuchen',
                              onPressed: () {
                                   Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => WebViewContainer()),
                                    );
                              },
                              color: Color(0xFF91306a),
                              assetImage: "assets/images/BowligBuchen.png",
                              startColor: Color.fromRGBO(89, 11, 58, 0.10), // Couleur de début du dégradé
                              endColor: Color(0xFF91306A),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Gallery',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CreatePostPage()),
                                );
                              },
                              color: Color(0xFFf9b334),
                              assetImage: "assets/images/Gallery.png",
                              startColor: Color.fromRGBO(89, 48, 11, 0.10), // Couleur de début du dégradé
                              endColor: Color(0xFFF9B334),
                            ),
                          ),
                          Expanded(
                            child: CustomButton(
                              text: 'Livescore',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MatchDetailsPage()),
                                );
                              },
                              color: Colors.teal,
                              assetImage: "assets/images/LiveScore.png",
                              startColor: Color.fromRGBO(11, 89, 89, 0.10), // Couleur de début du dégradé
                              endColor: Color(0xFF007C7C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QRViewExample()), // Replace with your shop page
                    );
                  },
                  borderRadius: BorderRadius.circular(8), // Ajoute un effet visuel lors du tap
                  child: Container(
                    height: 122,
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.1, color: Color(0xFFE6E7E9)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Aligner le texte à gauche
                            mainAxisAlignment: MainAxisAlignment.center, // Centrer verticalement
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top:10.0,left:10),
                                child: Text(
                                  "Speisekarte",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Color(0xFFE6E7E9),
                                    fontSize: 12.8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.left, // Aligner le texte à gauche
                                ),
                              ),
                              SizedBox(height: 5), // Espace entre les textes
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  "Scannen Sie den QR-Code,\num die Speisekarte zu durchsuchen",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Color(0xFFB3B3B3), // Couleur de texte
                                    fontSize: 14,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.left, // Aligner le texte à gauche
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Image.asset(
                            "assets/images/menu.png",
                            width: double.infinity, // Assure que l'image occupe toute la largeur
                            height: 100, // Ajuste la hauteur pour correspondre au bouton
                            fit: BoxFit.cover, // Ajuste l'image pour qu'elle couvre la zone disponible
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 450, // Hauteur du carrousel
                  child: PageView(
                    controller: _pageController,
                    children: [
                      ImageWithTextOverlay(
                        imagePath: 'assets/ForHomeScreen/image1.png',
                        title: "Fast wie in echt",
                        subtitle: "unsere Sportsimulationen",
                      ),
                      ImageWithTextOverlay(
                        imagePath: 'assets/ForHomeScreen/image2.png',
                        title: "24 Bowlingbahnen",
                        subtitle: "digital, brandneu, einfach",
                      ),
                      ImageWithTextOverlay(
                        imagePath: 'assets/ForHomeScreen/image3.png',
                        title: "B'MOOVD BIERGARTEN",
                        subtitle: "täglich geöffnet",
                      ),
                      ImageWithTextOverlay(
                        imagePath: 'assets/ForHomeScreen/image4.png',
                        title: "B'MOOVD BIERGARTEN",
                        subtitle: "täglich geöffnet",
                      ),
                      ImageWithTextOverlay(
                        imagePath: 'assets/ForHomeScreen/image5.png',
                        title: "B'MOOVD BIERGARTEN",
                        subtitle: "täglich geöffnet",
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Sponsoren",style:GoogleFonts.plusJakartaSans(fontSize: 16,fontWeight: FontWeight.bold,color: Color(0xFFCFCFCF))),
              ),
             Padding(
               padding: const EdgeInsets.only(bottom: 15.0),
               child: SizedBox(
                 height: 40,  // Hauteur que tu souhaites pour la zone de défilement
                 child: ListView(
                   scrollDirection: Axis.horizontal,  // Défilement horizontal
                   children: [
                     SizedBox(
                       child: Image.asset(
                         "assets/sponsors/sponsorss.png",
                         fit: BoxFit.cover,  // Ajuste l'image à la taille du conteneur
                       ),
                     ),
                   ],
                 ),
               ),
             )


            ],
          ),
        ],
      ),
     bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0, context: context,)
    );
  }
}
