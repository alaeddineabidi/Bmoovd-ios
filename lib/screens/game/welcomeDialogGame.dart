
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeDialog extends StatefulWidget {
  final List<dynamic> teams;

  const WelcomeDialog({Key? key, required this.teams}) : super(key: key);

  @override
  _WelcomeDialogState createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {
  late String selectedTeam;
    Future<void> saveBonusToFirestore(String champion) async {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .update({'champion': champion});
}

  @override
  void initState() {
    super.initState();
    selectedTeam = widget.teams[0]['league']['standings'][0][0]['team']['name'];
  }

  @override
  Widget build(BuildContext context) {
    var standings = widget.teams[0]['league']['standings'][0];

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
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.30),
              offset: Offset(0, 8.533),
              blurRadius: 17.067,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
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
            Center(child: Text("Wer ist der Champion dieser Saison?",style: GoogleFonts.plusJakartaSans(color:Color(0xffE6E7E9),fontSize: 14,fontWeight: FontWeight.w700),)),
            const SizedBox(height: 30),
            // Dropdown for team selection
            DropdownButton<String>(
              value: selectedTeam,
              icon: const Icon(Icons.arrow_downward, color: Colors.white),
              iconSize: 24,
              elevation: 16,
              dropdownColor: Color(0xFF21273D),
              style: const TextStyle(color: Colors.white),
              underline: Container(
                height: 2,
                color: const Color(0xff007C7C),
              ),
              borderRadius: BorderRadius.circular(10),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTeam = newValue!;
                });
              },
              items: standings.map<DropdownMenuItem<String>>((team) {
                return DropdownMenuItem<String>(
                  value: team['team']['name'],
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(team['team']["logo"],height: 30,),
                      ),
                      Text(
                        team['team']['name'],
                        style:  GoogleFonts.plusJakartaSans(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff007C7C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await saveBonusToFirestore(selectedTeam);
                Navigator.of(context).pop();
              },
              child: Text(
                'validieren',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}