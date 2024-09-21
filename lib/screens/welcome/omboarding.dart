import 'package:bmoovd/screens/HomeScreen/HomeScreen.dart';
import 'package:bmoovd/screens/auth/Login.dart';
import 'package:bmoovd/screens/auth/Register.dart';
import 'package:bmoovd/screens/staff/Home/staff_Home_Screen.dart';
import 'package:bmoovd/screens/welcome/Intro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoBackgroundPage extends StatefulWidget {
  @override
  _VideoBackgroundPageState createState() => _VideoBackgroundPageState();
}

class _VideoBackgroundPageState extends State<VideoBackgroundPage> {
  late VideoPlayerController _controller;
  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/output.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
        setState(() {});
      });
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstTime = prefs.getBool('first_time');

    setState(() {
      isFirstTime = firstTime == null || firstTime == true;
    });

    if (isFirstTime) {
    }
  }

  void _navigateToIntroPage(String buttonName) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => IntroPage(buttonClicked: buttonName,), // Rediriger vers la page d'intro
      ),
    );
  }

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_controller.value.isInitialized)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          else
            Center(child: CircularProgressIndicator()),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(32, 34, 43, 0.0),
                    Color.fromRGBO(26, 28, 32, 0.9),
                  ],
                  stops: [0.1, 0.8],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color.fromRGBO(32, 34, 43, 0.0),
                    Color.fromRGBO(26, 28, 32, 0.9),
                  ],
                  stops: [0.6, 0.8],
                ),
              ),
            ),
          ),
          Positioned(
            top:20,
            right: 0,
            left: 0,
            child: Image.asset("assets/logo/bmoovd_wortmarke_subline_wht.png",height: 70,)),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Center(
                  child: InkWell(
                    onTap: () async {
                      if (isFirstTime) {
                        _navigateToIntroPage("HomeScreen");
                            SharedPreferences prefs = await SharedPreferences.getInstance();

                        await prefs.setBool('first_time', false);

                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      }
                    },
                    child: Text(
                      "Melden Sie sich als Gast an",
                      style: GoogleFonts.plusJakartaSans(
                        color: Color(0xffE6E7E9),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xffE6E7E9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (isFirstTime) {
                            _navigateToIntroPage("Signup");
                            SharedPreferences prefs = await SharedPreferences.getInstance();

                        await prefs.setBool('first_time', false);

                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupPage()),
                            );
                          }
                        },
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(width: 2, color: Color(0xffB3B3B3)),
                          ),
                          child: Center(
                            child: Text(
                              "Registrieren",
                              style: GoogleFonts.plusJakartaSans(
                                color: Color(0xffE6E7E9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (isFirstTime) {
                            _navigateToIntroPage("LoginPage");
                            SharedPreferences prefs = await SharedPreferences.getInstance();

                        await prefs.setBool('first_time', false);

                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          }
                        },
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Color(0xff007C7C),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              "Login",
                              style: GoogleFonts.plusJakartaSans(
                                color: Color(0xffE6E7E9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                InkWell(
                  onTap: () async {
                          if (isFirstTime) {
                            _navigateToIntroPage("Google");
                            SharedPreferences prefs = await SharedPreferences.getInstance();

                        await prefs.setBool('first_time', false);

                          } else {
                            signInWithGoogle();
                          }
                        },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 2, color: Color(0xffB3B3B3)),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/icons/google1.png"),
                          SizedBox(width: 10),
                          Text(
                            "Mit Google anmelden",
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
