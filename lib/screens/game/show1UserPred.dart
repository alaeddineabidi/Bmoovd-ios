// ignore_for_file: file_names

import 'package:bmoovd/ClientApi/footballApi/football.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserPredictions extends StatelessWidget {
  final String userId;

  UserPredictions({required this.userId});

  Future<List<Map<String, dynamic>>> fetchUserPredictions() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final predictions = <Map<String, dynamic>>[];

    try {
      final userPredictionsSnapshot = await userDoc.collection('predictions').get();
      final userName = (await userDoc.get()).data()?['name'] ?? 'Unbekannt';

      for (var predictionDoc in userPredictionsSnapshot.docs) {
        final predictionData = predictionDoc.data();
        predictionData['userName'] = userName;

        final matchId = predictionData['matchId'];
        final matchDetails = await fetchMatchDetails(matchId);

        if (matchDetails != null && matchDetails["fixture"]['status']['short'] == 'NS') {
          predictionData['homeTeam'] = matchDetails['teams']['home'] ?? {};
          predictionData['awayTeam'] = matchDetails['teams']['away'] ?? {};
          predictionData['date'] = matchDetails['fixture']['date'] ?? 'Unbekannt';
          predictionData['time'] = matchDetails['fixture']['date']?.substring(11, 16) ?? 'Unbekannt';
          predictionData['where'] = matchDetails['fixture']['venue']['city'] ?? 'Unbekannt';
          predictions.add(predictionData);
        }
      }
      return predictions;
    } catch (e) {
      print('Fehler beim Abrufen der Vorhersagen: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchMatchDetails(String matchId) async {
    try {
      final matchDetailsList = await ApiServiceFootball.getMatchDetails([matchId]);
      if (matchDetailsList != null && matchDetailsList.isNotEmpty) {
        return matchDetailsList.first;
      } else {
        print('Keine Matchdetails für Match-ID: $matchId gefunden.');
        return null;
      }
    } catch (e) {
      print('Fehler beim Abrufen der Matchdetails für Match-ID $matchId: $e');
      return null;
    }
  }

  String _formatMatchDate(String dateString) {
    DateTime parsedDate = DateTime.parse(dateString);
    String formattedDate = "${parsedDate.year}.${parsedDate.month.toString().padLeft(2, '0')}.${parsedDate.day.toString().padLeft(2, '0')}";
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Center(child: Text("Freunden",style: GoogleFonts.plusJakartaSans(color: Color(0xffCFCFCF),fontSize: 16,fontWeight: FontWeight.w700),)) ,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset("assets/icons/back_arrow.png"),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUserPredictions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color:Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Keine Vorhersagen verfügbar.'));
          }

          final predictions = snapshot.data!;

          return ListView.builder(
            itemCount: predictions.length,
            itemBuilder: (context, index) {
              final prediction = predictions[index];
              final homeTeam = prediction['homeTeam'] ?? {};
              final awayTeam = prediction['awayTeam'] ?? {};
              final matchId = prediction['matchId'] ?? 'Unbekannt';
              final predictedScore = prediction['predictedScore'] ?? {'home': '-', 'away': '-'};
              final matchDate = prediction['date'] ?? 'Unbekannt';
              final matchTime = prediction['time'] ?? 'Unbekannt';
              final where = prediction["where"] ?? "Unbekannt";

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.85, color: const Color.fromRGBO(230, 231, 233, 0.50)),
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xff1A1C20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(19.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatMatchDate(matchDate),
                              style: GoogleFonts.plusJakartaSans(
                                color: Color(0xffB3B3B3),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "—",
                              style: GoogleFonts.plusJakartaSans(
                                color: Color(0xffB3B3B3),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              matchTime,
                              style: GoogleFonts.plusJakartaSans(
                                color: Color(0xffB3B3B3),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "—",
                              style: GoogleFonts.plusJakartaSans(
                                color: Color(0xffB3B3B3),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                where,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Color(0xffB3B3B3),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            homeTeam['logo'] != null
                                ? Image.network(
                                    homeTeam['logo'],
                                    width: 40,
                                    height: 40,
                                  )
                                : Container(width: 40, height: 40),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                homeTeam['name'] ?? 'Unbekannt',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Spacer(),
                            Container(
                              height: 41,
                              width: 65,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color(0xff15161A),
                                border: Border.all(width: 0.85, color: Color.fromRGBO(230, 231, 233, 0.50)),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${predictedScore['home']} - ${predictedScore['away']}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      color: Color(0xff80BDBD),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                            Expanded(
                              child: Text(
                                awayTeam['name'] ?? 'Unbekannt',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: 10),
                            awayTeam['logo'] != null
                                ? Image.network(
                                    awayTeam['logo'],
                                    width: 40,
                                    height: 40,
                                  )
                                : Container(width: 40, height: 40),
                          ],
                        ),
                        SizedBox(height: 10),
                        
                           
                            Center(
                              child: Text(
                                'Match ID: $matchId',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xffB3B3B3),
                                ),
                              ),
                            ),
                          
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
