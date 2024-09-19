import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class UserChatPage extends StatefulWidget {
  @override
  _UserChatPageState createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _sendMessage() {
    final user = _auth.currentUser;
    if (user != null && _controller.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(user.uid)
          .collection('messages')
          .add({
        'senderId': user.uid,
        'message': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
        'staffView': false,
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Chat mit dem Team',style : GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700,color: Color(0xffE6E7E9),fontSize: 16))),
       leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Image.asset("assets/icons/back_arrow.png")),
      
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(user!.uid)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Fehler: ${snapshot.error}'));
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
                    final isCurrentUser = message['senderId'] == user.uid;

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        margin: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Colors.blueAccent
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['message'],
                              style: GoogleFonts.plusJakartaSans(
                                  color: isCurrentUser
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            SizedBox(height: 5),
                          ],
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
                        cursorColor: Colors.grey, // Couleur du curseur
                        decoration: InputDecoration(
                          labelText: "schreibe dir eine Nachricht...",
                          labelStyle: GoogleFonts.plusJakartaSans(),
                          focusColor: Colors.grey,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color:  Colors.grey, // Couleur du bord quand le TextField n'est pas en focus
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.grey, // Couleur de la bordure en focus
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
  }
}
