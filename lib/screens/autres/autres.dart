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

  // Method to delete the user's account
Future<void> _confirmDeleteAccount() async {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17.067),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17.067),
            border: Border.all(
              color: const Color.fromRGBO(230, 231, 233, 0.60),
              width: 0.853,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(49, 58, 91, 0.00),
                Color(0xFF21273D),
              ],
            ),
            boxShadow: [
              const BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.30),
                offset: Offset(0, 8.533),
                blurRadius: 17.067,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xffE6E7E9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: const Color(0xff91306A),
                  ),
                  child: const Icon(Icons.close, size: 40),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Scheitern',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xffE6E7E9),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'Sind Sie sicher, dass Sie Ihr Konto löschen möchten?',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xffE6E7E9),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Champs de texte pour l'email
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffE6E7E9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffE6E7E9)),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Champs de texte pour le mot de passe
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffE6E7E9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffE6E7E9)),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Appel à la fonction de réauthentification
                          try {
                            await _reauthenticateAndDeleteAccount(
                              emailController.text,
                              passwordController.text,
                            );
                            Navigator.of(context).pop();
                          } catch (e) {
                            // Gérer les erreurs (par exemple, email ou mot de passe incorrect)
                            print('Erreur: $e');
                          }
                        }
                      },
                      child: const Text('Ja, löschen'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Abbrechen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _reauthenticateAndDeleteAccount(String email, String password) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

      // Réauthentification
      await user.reauthenticateWithCredential(credential);

      // Suppression du compte
      await user.delete();
      print('Compte supprimé avec succès.');
    }
  } catch (e) {
    print('Erreur lors de la suppression du compte: $e');
    throw e;
  }
}


Future<void> _deleteAccount() async {
  try {
    String userId = FirebaseAuth.instance.currentUser!.uid; // Récupère l'ID de l'utilisateur actuel
    
    // Supprime le document utilisateur dans Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();

    // Supprime l'utilisateur de Firebase Auth
    await FirebaseAuth.instance.currentUser!.delete();

    // Navigue vers un autre écran après la suppression
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  } catch (e) {
    print('Erreur lors de la suppression du compte : $e');
    // Gérer d'autres erreurs ici (par exemple, afficher un snackbar)
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                userName ?? "Unbekannt",
                                style: GoogleFonts.plusJakartaSans(
                                    color: Color(0xffE6E7E9),
                                    fontSize: 12.8,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.left,
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
            SizedBox(height: 16),
            const Divider(
              color: Colors.grey,
              thickness: 1.0,
            ),
            SizedBox(height: 16),
            Text("Hilfe und Unterstützung", style: GoogleFonts.plusJakartaSans(color: Color(0xffCFCFCF), fontSize: 16, fontWeight: FontWeight.w700),),
            SizedBox(height: 16),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserChatPage()),
                        );
                      },
                      child: Row(
                        children: [
                          Image.asset("assets/icons/chatStaff.png"),
                          const SizedBox(width: 10,),
                          Text("Chatten Sie mit dem Personal", style: GoogleFonts.plusJakartaSans(color: Color(0xffE6E7E9), fontSize: 14, fontWeight: FontWeight.w700))
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SpielregelnPage()),
                        );
                      },
                      child: Row(
                        children: [
                          Image.asset("assets/icons/Question.png"),
                          const SizedBox(width: 10,),
                          Text("Spielregeln", style: GoogleFonts.plusJakartaSans(color: Color(0xffE6E7E9), fontSize: 14, fontWeight: FontWeight.w700))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            const Divider(
              color: Colors.grey,
              thickness: 1.0,
            ),
            SizedBox(height: 16),
            Text("Einstellungen", style: GoogleFonts.plusJakartaSans(color: Color(0xffCFCFCF), fontSize: 16, fontWeight: FontWeight.w700),),
            SizedBox(height: 16),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PermissionNotif()),
                        );
                      },
                      child: Row(
                        children: [
                          Image.asset("assets/icons/Bell1.png"),
                          const SizedBox(width: 10,),
                          Text("Benachrichtigungen", style: GoogleFonts.plusJakartaSans(color: Color(0xffE6E7E9), fontSize: 14, fontWeight: FontWeight.w700))
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
                          user = null; // Update the user state to null after sign out
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Image.asset("assets/icons/Logout.png",color: Colors.red,),
                          const SizedBox(width: 10,),
                          Text("Abmelden", style: GoogleFonts.plusJakartaSans(color: Color(0xffE6E7E9), fontSize: 14, fontWeight: FontWeight.w700))
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
                      onTap: _confirmDeleteAccount, // Call the delete account method
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever,color: Colors.red,), // Add your delete icon here
                          const SizedBox(width: 10,),
                          Text("Konto löschen", style: GoogleFonts.plusJakartaSans(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w700))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 4, context: context,),
    );
  }
}
