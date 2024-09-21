import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String searchQuery = "";  // Variable to store the search query

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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase(); // Update search query
                });
              },
              decoration: InputDecoration(
                labelText: 'Search by name',
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Color(0xff1A1C20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No users found.'));
                }

                // Filter users based on search query
                final users = snapshot.data!.docs.where((doc) {
                  final userName = (doc.data() as Map<String, dynamic>)['name']?.toLowerCase() ?? '';
                  return userName.contains(searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return Center(child: Text('No users match the search.'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    final userId = users[index].id;
                    
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
                        'Email: ${user['email'] ?? 'No Email'}\n'
                        'Role: ${user['role'] ?? 'No Role'}\n'
                        'Points: ${user['points'] ?? 0}',
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
                      trailing: IconButton(
                        icon: Icon(Icons.restore, color: Colors.red),
                        onPressed: () {
                          _confirmResetDialog(context, userId, user['name']);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetDialog(BuildContext context, String userId, String? userName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset Points'),
          content: Text('Are you sure you want to reset points for ${userName ?? 'this user'}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _resetUserPoints(userId);
                Navigator.pop(context);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _resetUserPoints(String userId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'points': 0});
  }
}
