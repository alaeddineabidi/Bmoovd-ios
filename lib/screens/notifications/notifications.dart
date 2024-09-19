import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvitationsPage extends StatefulWidget {
  static const String routeName = "/notifications";
  final RemoteMessage? message;

  const InvitationsPage({super.key, this.message});

  @override
  _InvitationsPageState createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _acceptInvitation(String groupId, String userId) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      final userDocCurrent = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
      final groupDoc = userDoc.collection('groups').doc(groupId);

      final groupSnapshot = await groupDoc.get();
      if (groupSnapshot.exists) {
        final groupData = groupSnapshot.data()!;

        // Mise à jour du champ members du groupe
        await groupDoc.update({
          'members': FieldValue.arrayRemove([{'userId': currentUser!.uid, 'invitationAccepted': false}]),
        });

        await groupDoc.update({
          'members': FieldValue.arrayUnion([{'userId': currentUser!.uid, 'invitationAccepted': true}]),
        });

        await userDocCurrent.collection('groups').doc(groupId).set(groupData);

        await userDocCurrent.collection('groups').doc(groupId).update({
          'members': FieldValue.arrayUnion([{'userId': userId, 'invitationAccepted': true}]),
        });

        final invitationSnapshot = await userDocCurrent
            .collection('invitations')
            .where('groupId', isEqualTo: groupId)
            .get();

        if (invitationSnapshot.docs.isNotEmpty) {
          // Si un document est trouvé, le supprimer
          await invitationSnapshot.docs.first.reference.delete();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Einladung angenommen und Gruppe hinzugefügt.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Keine Einladung für diese Gruppe gefunden.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Das Gruppendokument existiert nicht.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    }
  }

  Future<void> _declineInvitation(String groupId) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    // Supprimer l'invitation sans la traiter
    await userDoc.collection('invitations').doc(groupId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Benachrichtigungen',
            style: GoogleFonts.plusJakartaSans(
              color: Color(0xffE6E7E9),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset("assets/icons/back_arrow.png"),
        ),
      ),
      body: Column(
        children: [
          if (widget.message != null) ...[
            // Afficher les détails de la notification
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.teal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Details',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Title: ${widget.message?.notification!.title ?? 'No Title'}',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                  ),
                  Text(
                    'Body: ${widget.message?.notification?.body ?? 'No Body'}',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Data: ${widget.message?.data.toString() ?? 'No Data'}',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .collection('invitations')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Fehler: ${snapshot.error}'));
                }
                if ((!snapshot.hasData || snapshot.data!.docs.isEmpty) && widget.message==null) {
                  // Afficher un message lorsque l'utilisateur n'a pas d'invitations
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/icons/nonotif.png"),
                        SizedBox(height: 10,),
                        Text(
                          "Keine Benachrichtigungen",
                          style: GoogleFonts.plusJakartaSans(
                            color: Color(0xffE6E7E9),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          "Wir informieren Sie, wenn es Neuigkeiten für Sie gibt.",
                          style: GoogleFonts.plusJakartaSans(
                            color: Color(0xff808080),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                final invitations = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: invitations.length,
                  itemBuilder: (context, index) {
                    final invitation = invitations[index];
                    final groupId = invitation['groupId'];
                    final userId = invitation['senderId'];

                    return FutureBuilder(
                      future: Future.wait([
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('groups')
                            .doc(groupId)
                            .get(),
                        FirebaseFirestore.instance.collection('users').doc(userId).get(),
                      ]),
                      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                        if (!snapshot.hasData) {
                          return ListTile(
                            title: Text('Laden...', style: GoogleFonts.plusJakartaSans(color: Colors.black)),
                          );
                        }

                        final groupDoc = snapshot.data![0];
                        final userDoc = snapshot.data![1];

                        if (!groupDoc.exists || !userDoc.exists) {
                          return ListTile(
                            title: Text('Informationen nicht verfügbar'),
                          );
                        }

                        // Extraire les informations nécessaires
                        final groupName = groupDoc['groupName'];
                        final senderName = userDoc['name'];

                        return Stack(
                          children: [
                            ListTile(
                              leading: Icon(Icons.notifications, color: Colors.teal),
                              title: Expanded(
                                child: Text(
                                  'Einladung zur Gruppe $groupName',
                                  style: GoogleFonts.plusJakartaSans(color: Color(0xffE6E7E9)),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gesendet von $senderName',
                                    style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                                  ),
                                  SizedBox(height: 4), // Espace entre le sender et "Akzeptiert"
                                  Text(
                                    'Akzeptiert',
                                    style: GoogleFonts.plusJakartaSans(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                onPressed: () async {
                                  await _declineInvitation(groupId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Einladung abgelehnt.')),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
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
}
