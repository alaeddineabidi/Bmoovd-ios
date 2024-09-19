import 'package:bmoovd/screens/HomeScreen/HomeScreen.dart';
import 'package:bmoovd/screens/notifications/firebaseNotifications.dart';
import 'package:bmoovd/screens/staff/Home/staff_Home_Screen.dart';
import 'package:bmoovd/screens/welcome/omboarding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Firebasenotifications().initNotifications();
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  Future<Widget> _getHomePage() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = userDoc.get('role');

      if (role == 'user') {
        return HomeScreen();
      } else if (role == 'admin') {
        return StaffHomePage();
      } else {
        return HomeScreen();
      }
    } else {
      return VideoBackgroundPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Splash Screen Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF15161A), // Set the background color to black
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Set default text color to white
          bodyMedium: TextStyle(color: Colors.white), // For other text styles
        ),
        
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF15161A),
          titleTextStyle: TextStyle(color: Colors.white), 
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.black, // Set drawer background color to black
          scrimColor: Colors.grey[900], 
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0D0D0D), // Set background color to grey
          selectedItemColor: Colors.white, // Set the selected item color to white
          unselectedItemColor: Colors.grey[400], // Set the unselected item color
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getHomePage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(), // Show a loading spinner while fetching user data
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
