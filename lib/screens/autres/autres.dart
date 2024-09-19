import 'package:bmoovd/screens/Chat_with_staff/users_chat_page.dart';
import 'package:bmoovd/screens/HomeScreen/HomeScreen.dart';
import 'package:bmoovd/screens/autres/Spielreglen.dart';
import 'package:bmoovd/screens/autres/notifpermission.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bmoovd/widgets/BottomNavigationBar.dart';

class Andere extends StatefulWidget {
  @override
  _AndereState createState() => _AndereState();
}

class _AndereState extends State<Andere> {
  String? userName;
  String? email;

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch the user's name when the widget is initialized
  }
  User? user;
  // Fetch the user's name from Firestore
  Future<void> _fetchUserName() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid; // Get current user's ID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      setState(() {
        userName = userDoc['name'];
        email = userDoc['email']; // Fetch the 'email' field
      });
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Andere',
          style: GoogleFonts.plusJakartaSans(
              color: Color(0xffE6E7E9), fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              Text(
                "Profil",
                style: GoogleFonts.plusJakartaSans(
                    color: Color(0xffCFCFCF), fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16),
              Stack(
                children: [
                  Container(
                    height: 122,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xffE6E7E9),
                        width: 0.0853,
                      ),
                      gradient: RadialGradient(
                        center: const Alignment(0.0851, -0.2418),
                        radius: 2.37,
                        colors: [
                          Color.fromRGBO(49, 58, 91, 0.10),
                          Color(0xFF21273D),
                        ],
                        stops: [0.302, 1],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40, // Adjust the size as needed
                            backgroundColor: Color(0xff859bb0), // Set the background color
                            child: userName != null
                                ? Text(
                                    userName![0].toUpperCase(), // Display the first letter of the user's name
                                    style: GoogleFonts.plusJakartaSans(
                                        color: Color(0xffCFCFCF), fontSize: 50, fontWeight: FontWeight.w700),
                                  )
                                : CircularProgressIndicator(), // Show a loading indicator until the name is fetched
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            // Make the column take the remaining width
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align the text to the left
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  userName ?? "Unbekannt",
                                  style: GoogleFonts.plusJakartaSans(
                                      color: Color(0xffE6E7E9),
                                      fontSize: 12.8,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.left, // Ensure text is aligned to the left
                                ),
                                SizedBox(height: 8.5),
                                Flexible(
                                  child: Text(
                                    "Email : $email",
                                    style: GoogleFonts.plusJakartaSans(
                                        color: Color(0xffB3B3B3),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                 
                ],
              ),
              SizedBox(height: 16,),
              const Divider(
                 color: Colors.grey,
                 thickness: 1.0,
              ),
              SizedBox(height: 16,),
              Text("Hilfe und Unterstützung",style: GoogleFonts.plusJakartaSans(color:Color(0xffCFCFCF),fontSize: 16,fontWeight: FontWeight.w700),),
              SizedBox(height: 16,),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.85,
                    color: Color.fromRGBO(230, 231, 233, 0.50)
                  ),
                  borderRadius: BorderRadius.circular(8)
                ),

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: (){
                           Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserChatPage()),
                            );
                        },
                        child: Row(
                          children: [
                              Image.asset("assets/icons/chatStaff.png"),
                              const SizedBox(width: 10,),
                              Text("Chatten Sie mit dem Personal",style:GoogleFonts.plusJakartaSans(color:Color(0xffE6E7E9),fontSize: 14,fontWeight: FontWeight.w700))
                          ],
                        ),
                      ),
                       const SizedBox(height: 5,),
                        const Divider(
                          color: Colors.grey,
                          thickness: 1.0,
                        ),
                        const SizedBox(height: 5,),
                       InkWell(
                        onTap: (){
                           Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SpielregelnPage()),
                            );
                        },
                         child: Row(
                          children: [
                            Image.asset("assets/icons/Question.png"),
                            const SizedBox(width: 10,),
                            Text("Spielregeln",style:GoogleFonts.plusJakartaSans(color:Color(0xffE6E7E9),fontSize: 14,fontWeight: FontWeight.w700))
                          ],
                                               ),
                       ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16,),
              const Divider(
                 color: Colors.grey,
                 thickness: 1.0,
              ),
              SizedBox(height: 16,),
              Text("Einstellungen",style: GoogleFonts.plusJakartaSans(color:Color(0xffCFCFCF),fontSize: 16,fontWeight: FontWeight.w700),),
              SizedBox(height: 16,),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.85,
                    color: Color.fromRGBO(230, 231, 233, 0.50)
                  ),
                  borderRadius: BorderRadius.circular(8)
                ),

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: (){
                           Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PermissionNotif()),
                            );
                        },
                        child: Row(
                          children: [
                              Image.asset("assets/icons/Bell1.png"),
                              const SizedBox(width: 10,),
                              Text("Benachrichtigungen",style:GoogleFonts.plusJakartaSans(color:Color(0xffE6E7E9),fontSize: 14,fontWeight: FontWeight.w700))
                          ],
                        ),
                      ),
                       const SizedBox(height: 5,),
                        const Divider(
                          color: Colors.grey,
                          thickness: 1.0,
                        ),
                        const SizedBox(height: 5,),
                       InkWell(
                        onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            setState(() {
                              user = null; // Update the user state to null after logout
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                            );
                          
                        },
                         child: Row(
                          children: [
                            Image.asset("assets/icons/Logout.png"),
                            const SizedBox(width: 10,),
                            Text("ausloggen",style:GoogleFonts.plusJakartaSans(color:Color(0xffE6E7E9),fontSize: 14,fontWeight: FontWeight.w700))
                          ],
                                               ),
                       ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 4,
        context: context,
      ),
    );
  }
}
