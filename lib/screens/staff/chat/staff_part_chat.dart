import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Gespräche',style: GoogleFonts.poppins(fontWeight: FontWeight.bold),)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucun utilisateur trouvé.'));
          }

          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userEmail = userDoc['email'];
              final chatId = userDoc.id;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> messageSnapshot) {
                  if (messageSnapshot.hasError) {
                    return Container(); // Hide the item if there's an error
                  }

                  if (messageSnapshot.connectionState == ConnectionState.waiting) {
                    return Container(); // Hide the item while loading
                  }

                  if (!messageSnapshot.hasData || messageSnapshot.data!.docs.isEmpty) {
                    return Container(); // Hide the item if no messages
                  }

                  final lastMessage = messageSnapshot.data!.docs.first;
                  final messageData = lastMessage.data() as Map<String, dynamic>;
                  final bool isBold = messageData.containsKey('staffView')
                      ? !messageData['staffView']
                      : true; // Default to bold if staffView doesn't exist
                  final lastMessageText = messageData['message'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: isBold? Colors.teal : Colors.transparent,),
                      
                      child: ListTile(
                        title: Text(
                          '$userEmail',
                          style: GoogleFonts.poppins(fontWeight: isBold ? FontWeight.bold : FontWeight.normal,color: Colors.white),
                        ),
                        subtitle: Text(
                          lastMessageText,
                          style: GoogleFonts.poppins(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
                        ),
                        onTap: () {
                          if (messageData.containsKey('staffView') && !messageData['staffView']) {
                            // Mark the last message as seen
                            lastMessage.reference.update({'staffView': true});
                          }
                      
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StaffChatDetailPage(chatId: chatId),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
class StaffChatDetailPage extends StatelessWidget {
  final String chatId;

  StaffChatDetailPage({required this.chatId});

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'message': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  Future<String?> _getUserEmail(String chatId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(chatId)
        .get();

    return userDoc['email'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserEmail(chatId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Laden...',style:GoogleFonts.poppins(fontWeight: FontWeight.bold))),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final String userEmail = snapshot.data ?? 'Benutzer';
        return Scaffold(
          appBar: AppBar(
            title: Text('$userEmail',style: GoogleFonts.poppins(fontWeight: FontWeight.bold),),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final messages = snapshot.data!.docs;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isCurrentUser = message['senderId'] == FirebaseAuth.instance.currentUser!.uid;
                        return Align(
                          alignment: isCurrentUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 8.0),
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Colors.blue
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              message['message'],
                              style: GoogleFonts.poppins(
                                color: isCurrentUser
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        cursorColor: Colors.blue, // Couleur du curseur
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.message, color: Colors.blue), // Couleur de l'icône
                          focusColor: Colors.blue,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color:  Colors.blue, // Couleur du bord quand le TextField n'est pas en focus
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.blue, // Couleur de la bordure en focus
                              width: 2.0,
                            ),
                          ),
                         
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                        style: GoogleFonts.poppins(color: Colors.blue), 
                      ),


                    ),
                    IconButton(
                      icon: Icon(Icons.send,color: Colors.blue,),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
