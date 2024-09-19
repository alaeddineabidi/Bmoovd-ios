import 'package:bmoovd/screens/auth/Login.dart';
import 'package:bmoovd/screens/staff/chat/staff_part_chat.dart';
import 'package:bmoovd/screens/staff/posts/posts.dart';
import 'package:bmoovd/screens/staff/users/users.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
class StaffHomePage extends StatelessWidget {
  const StaffHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startseite',style: GoogleFonts.poppins(fontWeight: FontWeight.bold),), 
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(),
              child: Text(
                'Menükopf', // "Drawer Header" en allemand
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: Text(
                'Chat', 
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () {
                // Naviguer vers la page de chat
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StaffChatPage()), // Naviguer vers StaffChatPage
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Einstellungen'), // "Settings" en allemand
              onTap: () {
                // Naviguer vers la page des paramètres
                
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('users'), 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UsersPage()), // Naviguer vers StaffChatPage
                );
              },
            ),ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Posts'), 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminPostsPage()), // Naviguer vers StaffChatPage
                );
              },
            )
          ],
        ),
      ),
      body: const Center(
        child: Text('Willkommen auf der Startseite!'), // "Welcome to the Home Page!" en allemand
      ),
    );
  }
}
