import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Users List',
            style: GoogleFonts.plusJakartaSans(
              color: Color(0xffE6E7E9),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        backgroundColor: Color(0xff1A1C20),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(
                  user['name'] ?? 'No Name',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  'Email: ${user['email'] ?? 'No Email'}\nRole: ${user['role'] ?? 'No Role'}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.0,
                    color: Colors.grey[400],
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                tileColor: Color(0xff1A1C20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
