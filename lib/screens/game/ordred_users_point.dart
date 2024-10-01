
import 'dart:io';

import 'package:bmoovd/screens/game/show1UserPred.dart';
import 'package:bmoovd/screens/notifications/sendNotifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<String> selectedUserIds = [];
  String groupName = '';
  bool showAllUsers = true;
  User? currentUser;
  bool hasGroups = false;
void _createGroup(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      String searchQuery = '';
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Color(0xFF15161A),
            title: Text(
              'Erstellen Sie eine neue Gruppe',
              style: GoogleFonts.plusJakartaSans(color: Color(0xffCFCFCF), fontSize: 14, fontWeight: FontWeight.w600),
            ),
            content: Container(
              width: double.maxFinite, // Make the dialog content expand to the max width
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Adjusts to the size of its children
                  children: [
                    // Group name input field
                    TextField(
                      style: GoogleFonts.poppins(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          groupName = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Gruppenname',
                        hintStyle: GoogleFonts.plusJakartaSans(color: Color.fromRGBO(230, 231, 233, 0.40)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xff007C7C)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // User search field
                    TextField(
                      style: GoogleFonts.poppins(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'suchen...',
                        hintStyle: GoogleFonts.plusJakartaSans(color: Color.fromRGBO(230, 231, 233, 0.40)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xff007C7C)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // User list that can be scrollable
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('name', isGreaterThanOrEqualTo: searchQuery)
                          .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Erreur: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        final users = snapshot.data!.docs;
                        if (users.isEmpty) {
                          return Center(child: Text('Aucun utilisateur trouvé.'));
                        }
                        return Container(
                          height: 300, // Set a fixed height for the ListView
                          child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              final userId = user.id;
                              final userName = user['name'];

                              return ListTile(
                                title: Text(
                                  userName,
                                  style: GoogleFonts.plusJakartaSans(color: Color(0xffCFCFCF)),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    selectedUserIds.contains(userId)
                                        ? Icons.check_circle
                                        : Icons.add_circle,
                                    color: Color(0xff007C7C),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (selectedUserIds.contains(userId)) {
                                        selectedUserIds.remove(userId);
                                      } else {
                                        selectedUserIds.add(userId);
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text('Stornieren', style: GoogleFonts.plusJakartaSans(color: Color(0xffCFCFCF))),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('erstellen', style: GoogleFonts.plusJakartaSans(color: Color(0xff007C7C), fontWeight: FontWeight.w700)),
                onPressed: () async {
                  if (groupName.isNotEmpty && selectedUserIds.isNotEmpty) {
                    await _saveGroupToFirestore(); // Make sure this method is defined
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}







  Future<void> _saveGroupToFirestore() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
  final groupCollection = userDoc.collection('groups');

  // Créer une liste de membres avec le statut d'invitation non acceptée
  List<Map<String, dynamic>> membersWithStatus = selectedUserIds.map((userId) {
    return {
      'userId': userId,
      'invitationAccepted': false,
    };
  }).toList();

  // Ajouter le groupe dans Firestore
  DocumentReference groupRef = await groupCollection.add({
    'groupName': groupName,
    'members': membersWithStatus,
  });

  // Envoyer une invitation et une notification à chaque utilisateur invité
  for (String userId in selectedUserIds) {
    await _sendInvitation(userId, groupRef.id, currentUser.uid);
  }
}

Future<void> _sendInvitation(String userId, String groupId, String senderId) async {
  try {
    // Enregistrer l'invitation dans Firestore
    final invitationDoc = FirebaseFirestore.instance.collection('users').doc(userId).collection('invitations');
    await invitationDoc.add({
      'groupId': groupId,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      String? fcmToken = userDoc['fcmToken']; 

      if (fcmToken != null) {
        String notificationTitle = 'Neue Gruppeneinladung';
        String notificationBody = 'Sie wurden eingeladen, der Gruppe $groupName beizutreten';
        await NotificationService.sendNotification(fcmToken, notificationTitle, notificationBody);
        print('Invitation envoyée à $userId pour le groupe $groupId');
      } else {
        print('Token FCM non disponible pour l\'utilisateur $userId');
      }
    }
  } catch (e) {
    print('Erreur lors de l\'envoi de l\'invitation et de la notification: $e');
  }
}

 
  List<String> acceptedMembers = [];
    Map<String, List<String>> groupMembersMap = {};

bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchAcceptedMembers();
  }
    


 Future<void> _fetchAcceptedMembers() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var groupsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('groups')
          .get();

      if (groupsSnapshot.docs.isNotEmpty) {
        Map<String, List<String>> membersMap = {};

        for (var groupDoc in groupsSnapshot.docs) {
          String groupName = groupDoc['groupName'];
          var members = groupDoc['members'] as List<dynamic>;
          List<String> acceptedMembers = [];

          for (var member in members) {
            if (member['invitationAccepted'] == true) {
              acceptedMembers.add(member['userId']); // Ajouter les utilisateurs acceptés
            }

            setState(() {
              
            });
          }

          if (acceptedMembers.isNotEmpty) {
            membersMap[groupName] = acceptedMembers;
          }
        }

        setState(() {
          groupMembersMap = membersMap;
          hasGroups = true;
        });
      } else {
        // Si la collection `groups` est vide
        setState(() {
          hasGroups = false;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading){
      return Center(child : CircularProgressIndicator());
    }
    return  Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(right:20.0),
            child: Center(
              child: Text(
                'Bestenliste',
                style: GoogleFonts.plusJakartaSans(
                  color: Color(0xffCFCFCF),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildToggleButton('Alle Benutzer', showAllUsers),
                  SizedBox(width: 10),
                  _buildToggleButton('Persönliche Gruppe', !showAllUsers),
                ],
              ),
            ),
            Expanded(
              child: showAllUsers ? _buildAllUsersList() : _buildGroupUsersList(),
            ),
          ],
        ),
      );
    
  }

  // Bouton pour basculer entre afficher tous les utilisateurs ou seulement les utilisateurs du groupe
  Widget _buildToggleButton(String text, bool isActive) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            showAllUsers = text == 'Alle Benutzer';
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? Color.fromRGBO(0, 124, 124, 0.60)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: Color.fromRGBO(230, 231, 233, 0.50),
              width: 0.85,
            ),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              color: isActive ? Color(0xFFE6E7E9) : Color(0xff80BDBD),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildAllUsersList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('users').orderBy('points', descending: true).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Erreur: ${snapshot.error}'));
      }
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }
      final users = snapshot.data!.docs;
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final userData = user.data() as Map<String, dynamic>?; // Ensure it's treated as a Map

          final name = (userData != null && userData.containsKey('name')) ? userData['name'] : "user";
          final points = userData?['points'] ?? 0;
          final position = index + 1;
          return  Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildUserTile(name, points, position),
            );
        },
      );
    },
  );
}
Widget _buildGroupUsersList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('groups')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => _createGroup(context),
                child: CircleAvatar(
                  backgroundColor: Color(0xff007C7C),
                  child: Icon(Icons.add, size: 25, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 20, left: 20, right: 20),
                child: Center(
                  child: Text(
                    "Um die Vorhersagen Ihrer Freunde zu verfolgen. Bitte erstellen Sie eine persönliche Gruppe",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                        color: Color(0xff909191),
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Map pour stocker les membres acceptés par groupe
      Map<String, List<String>> groupMembersMap = {};

      for (var groupDoc in snapshot.data!.docs) {
        String groupName = groupDoc['groupName'];
        var members = groupDoc['members'] as List<dynamic>;
        List<String> acceptedMembers = [];

        for (var member in members) {
          if (member['invitationAccepted'] == true) {
            acceptedMembers.add(member['userId']);
          }
        }

        if (acceptedMembers.isNotEmpty) {
          groupMembersMap[groupName] = acceptedMembers;
        }
      }

      if (groupMembersMap.isEmpty) {
        return Center(
          child: Text(
            'Aucun membre n\'a accepté l\'invitation',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18),
          ),
        );
      }

      Future<Map<String, Map<String, dynamic>>> _fetchUserDetails(List<String> userIds) async {
        Map<String, Map<String, dynamic>> userDetails = {};
        for (String userId in userIds) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          if (userDoc.exists) {
            userDetails[userId] = {
              'name': userDoc['name'] ?? 'Nom inconnu',
              'points': userDoc['points'] ?? 0,
            };
          }
        }
        return userDetails;
      }

      return Column(
        children: [
          Expanded(
            child: ListView(
              children: groupMembersMap.keys.map((groupName) {
                List<String> members = groupMembersMap[groupName] ?? [];

                return FutureBuilder<Map<String, Map<String, dynamic>>>(
                  future: _fetchUserDetails(members),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text(
                          'Laden...',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return ListTile(
                        title: Text(
                          'Fehler beim Laden',
                          style: GoogleFonts.plusJakartaSans(color: Colors.red, fontSize: 16),
                        ),
                      );
                    }

                    final userDetails = snapshot.data ?? {};
                    List<MapEntry<String, Map<String, dynamic>>> sortedUserDetails = userDetails.entries.toList()
                      ..sort((a, b) => b.value['points'].compareTo(a.value['points']));

                    return ExpansionTile(
                      iconColor: Color(0xffCFCFCF),
                      title: Text(
                        '$groupName',
                        style: GoogleFonts.plusJakartaSans(color: Color(0xffCFCFCF), fontSize: 18),
                      ),
                      children: sortedUserDetails.map((entry) {
                        String userId = entry.key; // Récupère l'UID du user
                        String userName = entry.value['name'];
                        int points = entry.value['points'];

                        final position = sortedUserDetails.indexOf(entry) + 1;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xff1A1C20),
                              border: Border.all(
                                color: Color.fromRGBO(230, 231, 233, 0.50),
                                width: 0.85,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                // Navigate to UserPredictions with the selected user's UID
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserPredictions(userId: userId),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: position <= 3
                                    ? Image.asset(
                                        position == 1
                                            ? 'assets/icons/Trophy1.png'
                                            : position == 2
                                                ? 'assets/icons/Trophy2.png'
                                                : 'assets/icons/Trophy3.png',
                                      )
                                    : Container(
                                        height: 25,
                                        width: 25,
                                        child: CircleAvatar(
                                          backgroundColor: Color(0xffE6E7E9),
                                          child: Text(
                                            '$position',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Color.fromRGBO(21, 22, 26, 0.80),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                title: Text(
                                  userName,
                                  style: GoogleFonts.plusJakartaSans(color: Color(0xFFE6E7E9)),
                                ),
                                trailing: Text(
                                  points.toString(),
                                  style: GoogleFonts.plusJakartaSans(color: Color(0xFFE6E7E9)),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          Platform.isIOS ?
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                _createGroup(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Color.fromRGBO(230, 231, 233, 0.50),
                    width: 0.85,
                  ),
                ),
              ),
              child: SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xff007C7C),
                        child: Icon(Icons.add, size: 25, color: Colors.black),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          
                          "Erstelle eine persönliche Gruppe"
,
                          style: GoogleFonts.plusJakartaSans(color: Color(0xffE6E7E9), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ) : 
            Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                _createGroup(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Color.fromRGBO(230, 231, 233, 0.50),
                    width: 0.85,
                  ),
                ),
              ),
              child: SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xff007C7C),
                        child: Icon(Icons.add, size: 25, color: Colors.black),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Erstellen Sie eine \npersönliche Gruppe",
                          style: GoogleFonts.plusJakartaSans(color: Color(0xffE6E7E9), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}


  Widget _buildUserTile(String name, int points, int position) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff1A1C20),
        border: Border.all(
          color: Color.fromRGBO(230, 231, 233, 0.50),
          width: 0.85,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: position <= 3
            ? Image.asset(
                position == 1
                    ? 'assets/icons/Trophy1.png'
                    : position == 2
                        ? 'assets/icons/Trophy2.png'
                        : 'assets/icons/Trophy3.png',
              )
            :Container(
              height: 25,
              width: 25,
              child: CircleAvatar(
                  backgroundColor: Color(0xffE6E7E9),
                  child: Text(
                      '$position',
                      style: GoogleFonts.plusJakartaSans(
                        color: Color.fromRGBO(21, 22, 26, 0.80),
                        fontWeight: FontWeight.w700,
                        fontSize: 10
                      ),
                    ),
                ),
            ),
            
        title: Text(
          name,
          style: GoogleFonts.plusJakartaSans(color: Color(0xFFE6E7E9)),
        ),
        trailing: Text(
          points.toString(),
          style: GoogleFonts.plusJakartaSans(color: Color(0xFFE6E7E9)),
        ),
      ),
    );
  }
}
