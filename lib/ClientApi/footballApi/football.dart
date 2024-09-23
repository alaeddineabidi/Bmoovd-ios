import 'dart:convert';
import 'dart:ui';
import 'package:bmoovd/constant/apiConfig/api-header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;



class ApiServiceFootball {
  static Future<List<dynamic>?> fetchMatchDetails() async {
    final url = Uri.parse('https://v3.football.api-sports.io/fixtures?live=all');
    final response = await http.get(url, headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['response'];
    } else {
      print("No data ${response.statusCode}");
      return null;
    }
  }
  static Future<List<dynamic>?> fetchStandings(int year) async {
    final url = Uri.parse('https://v3.football.api-sports.io/standings?league=78&season=$year');
    final response = await http.get(url, headers: ApiConfig.headers);
    if (response.statusCode == 200) {
      
      return jsonDecode(response.body)['response'];
    } else {
      print("No data ${response.statusCode}");
      return null;
    }
  }

 static Future<Map<String, dynamic>?> fetchCurrentLeague() async {
  final url = Uri.parse('https://v3.football.api-sports.io/leagues?id=78');
  final response = await http.get(url, headers: ApiConfig.headers);
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['response'];
    final currentSeason = data[0]['seasons'].firstWhere((season) => season['current'] == true, orElse: () => null);
    print(currentSeason);
    
    if (currentSeason != null) {
      return {
        'league': data[0]['league'],
        'country': data[0]['country'],
        'season': currentSeason
      };
    }
  } else {
    print("No data ${response.statusCode}");
  }
  return null;
}
  

  static Future<List<dynamic>?> fetchMatchDetailsNS() async {
    final url = Uri.parse('https://v3.football.api-sports.io/fixtures?league=78&season=2024&status=NS');
    final response = await http.get(url, headers: ApiConfig.headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['response'];
    } else {
      print("No data ${response.statusCode}");
      return null;
    }
  }

  static Future<List<dynamic>?> getMatchWithId(int id) async {
    final url = Uri.parse('https://v3.football.api-sports.io/fixtures?id=$id');
    final response = await http.get(url, headers: ApiConfig.headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['response'];
    } else {
      print("No data ${response.statusCode}");
      return null;
    }
  }

 static Future<void> submitPrediction(
    BuildContext context, String matchId, int homeScore, int awayScore, String matchStatus) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return;
  }
  final userId = user.uid;

  try {
    // Vérifiez si le matchId existe déjà dans les prédictions de l'utilisateur
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('predictions')
        .where('matchId', isEqualTo: matchId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Si le match existe déjà, afficher un showDialog
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligne les éléments avec de l'espace entre eux
                  children: [
                    const Spacer(), 
                    InkWell(
                      onTap: (){
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

                  const SizedBox(height: 30,),
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100),color: const Color(0xff91306A)),
                    child:const Icon(Icons.close,size: 40,)
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Scheitern',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xffE6E7E9), fontSize: 18,fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 30),
                   Center(
                     child: Text(
                        'Ihre Vorhersage wurde nicht korrekt übermittelt. Versuchen Sie es erneut.',
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xffE6E7E9),fontSize: 14,fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                   ),
                  
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Si le match n'existe pas encore, soumettre la prédiction
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('predictions')
          .add({
        'matchId': matchId,
        'predictedScore': {
          'home': homeScore,
          'away': awayScore,
        },
      });

      // Afficher un dialogue de succès après l'ajout de la prédiction
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligne les éléments avec de l'espace entre eux
                  children: [
                    const Spacer(), // Utilisé pour pousser l'icône à droite
                    InkWell(
                      onTap: (){
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

                  const SizedBox(height: 30,),
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(100),color: const Color(0xff007C7C)),
                    child:const Icon(Icons.check,size: 40,)
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Erfolg',
                      style: GoogleFonts.plusJakartaSans(color: const Color(0xffE6E7E9), fontSize: 18,fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 30),
                   Center(
                     child: Text(
                        'Ihre Vorhersage wurde nicht korrekt übermittelt. Versuchen Sie es erneut.',
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xffE6E7E9),fontSize: 14,fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                   ),
                  
                ],
              ),
            ),
          );
        },
      );
    }
  } catch (e) {
    print("Erreur lors de la soumission de la prédiction: $e");
  }
}



  static Future<void> updateActualScore(String matchId, int homeScore, int awayScore) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    final userId = user.uid;
    try {
      final predictions = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('predictions')
          .where('matchId', isEqualTo: matchId)
          .get();

      for (var doc in predictions.docs) {
        final docRef = doc.reference;
        final predictedScore = doc['predictedScore'];
        final actualScore = {
          'home': homeScore,
          'away': awayScore,
        };

        if (predictedScore['home'] == homeScore && predictedScore['away'] == awayScore) {
          await docRef.update({
            'status': 'correct',
            'actualScore': actualScore,
          });
          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'points': FieldValue.increment(10),
          });
        } else {
          await docRef.update({
            'status': 'incorrect',
            'actualScore': actualScore,
          });
        }
      }
    } catch (e) {
      print("Error updating actual score: $e");
    }
  }

  static Future<List<dynamic>?> getMatchDetails(List<String> ids) async {
    final List<dynamic> allMatches = [];

    for (String id in ids) {
      final url = Uri.parse('https://v3.football.api-sports.io/fixtures?id=$id');
      final response = await http.get(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final matchData = jsonDecode(response.body)['response'];
        if (matchData != null) {
          allMatches.addAll(matchData);
          print("ahouma    $allMatches");
        }
      } else {
        print("No data for ID $id: ${response.statusCode}");
      }
    }

    return allMatches;
  }
}
