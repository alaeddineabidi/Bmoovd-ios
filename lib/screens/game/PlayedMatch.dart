import 'package:bmoovd/ClientApi/FirebaseService/match_service.dart';
import 'package:bmoovd/ClientApi/footballApi/football.dart';
import 'package:bmoovd/screens/game/OtherUsersPredictions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PlayedMatches extends StatefulWidget {
  @override
  _PlayedMatchesState createState() => _PlayedMatchesState();
}

class _PlayedMatchesState extends State<PlayedMatches> {
  Future<Map<String, dynamic>?>? _matchDetailsAndPredictions;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchMatchDetails();
  }
  String _formatMatchDate(String dateString) {
  DateTime parsedDate = DateTime.parse(dateString); // Convertir la chaîne en DateTime
  String formattedDate = "${parsedDate.year}.${parsedDate.month.toString().padLeft(2, '0')}.${parsedDate.day.toString().padLeft(2, '0')}"; 
  return formattedDate; // Retourner la date formatée avec des points
}

String _formatMatchTime(String dateTime) {
  final DateTime date = DateTime.parse(dateTime);
  final DateFormat timeFormat = DateFormat('HH:mm');
  final String formattedTime = timeFormat.format(date);
  return '$formattedTime';
}

  Future<void> _fetchMatchDetails() async {
    try {
      final matchDetailsAndPredictions = await MatchService.getMatchDetailsAndPredictions();
      final matchIds = matchDetailsAndPredictions.keys.toList();
      final userId = MatchService.getCurrentUserId();

      if (matchIds.isNotEmpty) {
        final details = await ApiServiceFootball.getMatchDetails(matchIds);

        for (var match in details!) {
          final matchId = match['fixture']['id'].toString();
          final predictedScore = matchDetailsAndPredictions[matchId];
          final matchStatus = match['fixture']['status']['short'] ?? '';
          final homeScore = match['score']['fulltime']['home'] ?? 0;
          final awayScore = match['score']['fulltime']['away'] ?? 0;

          if (matchStatus == 'FT' || matchStatus == 'AET') {
            if (predictedScore != null) {
              if (predictedScore['home'] == homeScore && predictedScore['away'] == awayScore) {
                await MatchService.updateUserPoints(userId, 10, matchId);
              } else if ((predictedScore['home']! > predictedScore['away']! && homeScore > awayScore) ||
                  (predictedScore['away']! > predictedScore['home']! && awayScore > homeScore)) {
                await MatchService.updateUserPoints(userId, 5, matchId);
              }
            }
          }
        }

        setState(() {
          _matchDetailsAndPredictions = Future.value({
            'matches': details,
            'predictions': matchDetailsAndPredictions,
          });
        });
      }
    } catch (e) {
      print('Fehler beim Abrufen der Matchdetails: $e');
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Gespielte Spiele',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700,color: Color(0xffE6E7E9),fontSize: 16),
            textAlign: TextAlign.center,
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
          Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: () => _onTabSelected(0),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedIndex == 0
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
          'Persönlich',
          style: GoogleFonts.plusJakartaSans(
            color: _selectedIndex == 0 ? Color(0xFFE6E7E9) : Color(0xff80BDBD),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ),
    SizedBox(width: 10),
    ElevatedButton(
      onPressed: () => _onTabSelected(1),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedIndex == 1
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
          'Alle Benutzer',
          style: GoogleFonts.plusJakartaSans(
            color: _selectedIndex == 1 ? Color(0xFFE6E7E9) : Color(0xff80BDBD),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ),
  ],
),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                FutureBuilder<Map<String, dynamic>?>(
                  future: _matchDetailsAndPredictions,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Colors.teal,));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Fehler: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || (snapshot.data!['matches'] as List<dynamic>).isEmpty) {
                      return Center(child: CircularProgressIndicator(color: Colors.teal,));
                    }
                    final matches = snapshot.data!['matches'] as List<dynamic>;
                    final predictions = snapshot.data!['predictions'] as Map<String, Map<String, int>?>;
                    return ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        final homeTeam = match['teams']['home'] ?? {};
                        final awayTeam = match['teams']['away'] ?? {};
                        final matchId = match['fixture']['id'].toString();
                        final predictedScore = predictions[matchId];
                        final matchStatus = match['fixture']['status']['short'] ?? '';

                        Color cardColor;
                        Color scoreColor;
                        String statusText;

                        if (matchStatus == 'FT' || matchStatus == 'AET') {
                          final homeScore = match['score']['fulltime']['home'] ?? 0;
                          final awayScore = match['score']['fulltime']['away'] ?? 0;
                          if (predictedScore != null &&
                              predictedScore['home'] == homeScore &&
                              predictedScore['away'] == awayScore) {
                            cardColor = Color.fromRGBO(0, 124, 124, 0.20);
                            scoreColor = Color(0xff1D2525);
                            statusText = 'Match Finished';
                          } else {
                            cardColor = Color.fromRGBO(145, 48, 106, 0.20);
                            scoreColor = Color(0xff1F0A16);
                            statusText = 'Match Finished';
                          }
                        } else if ([
                          '1H', 'HT', '2H', 'ET', 'BT', 'P', 'SUSP', 'INT', 'NS'
                        ].contains(matchStatus)) {
                          cardColor = Colors.grey[900]!;
                          scoreColor = Color(0xff15161A);
                          statusText = 'Laufend';
                        } else {
                          cardColor = Colors.grey[900]!;
                          scoreColor = Color(0xff15161A);
                          statusText = '${matchStatus.isEmpty ? 'Unbekannt' : matchStatus}';
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                style: BorderStyle.solid,
                                color: Color.fromRGBO(230, 231, 233, 0.50),
                                width: 0.85,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: cardColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_formatMatchDate(match['fixture']['date']),
                                          style: GoogleFonts.plusJakartaSans(
                                              color: Color(0xffB3B3B3), fontSize: 14, fontWeight: FontWeight.w400)),
                                      Text("—",
                                          style: GoogleFonts.plusJakartaSans(
                                              color: Color(0xffB3B3B3), fontSize: 14, fontWeight: FontWeight.w400)),
                                      Text(_formatMatchTime(match['fixture']['date']),
                                          style: GoogleFonts.plusJakartaSans(
                                              color: Color(0xffB3B3B3), fontSize: 14, fontWeight: FontWeight.w400)),
                                      Text("—",
                                          style: GoogleFonts.plusJakartaSans(
                                              color: Color(0xffB3B3B3), fontSize: 14, fontWeight: FontWeight.w400)),
                                      Text("${match["fixture"]["venue"]["city"]}",
                                          style: GoogleFonts.plusJakartaSans(
                                              color: Color(0xffB3B3B3), fontSize: 14, fontWeight: FontWeight.w400)),
                                    ],
                                  ),
                                  SizedBox(height: 10),
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
                                      Flexible(
                                        child: Text(
                                          homeTeam['name'] ?? 'Unknown',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                        Container(
                                          height: 41,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: scoreColor,
                                            border: Border.all(width: 0.85,color: Color.fromRGBO(230, 231, 233, 0.50))
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                  (match['score']['fulltime']['home'] != null && match['score']['fulltime']['away'] != null)
                                                      ? '${match['score']['fulltime']['home']} - ${match['score']['fulltime']['away']}'
                                                      : '-',
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
                                      Flexible(
                                        child: Text(
                                          awayTeam["name"] ?? "Unknown",
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                  SizedBox(height: 30),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Ihre \n   Vorhersage",style: GoogleFonts.plusJakartaSans(color:Color(0xffE6E7E9),fontSize: 16,fontWeight: FontWeight.w500),),
                                      Center(

                                             child: Container(
                                                height: 41,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),
                                                  color: scoreColor,
                                                  border: Border.all(width: 0.85,color: Color.fromRGBO(230, 231, 233, 0.50))
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      '${predictedScore!["home"]} - ${predictedScore['away']}',
                                                      style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 18, color: Color(0xff80BDBD), fontWeight: FontWeight.w700),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                                                                 
                                        
                                      ),
                                       Text("$statusText",style: GoogleFonts.plusJakartaSans(color:Color(0xffE6E7E9),fontSize: 14,fontWeight: FontWeight.w500),),

                                    ],
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
                Center(
  child: OtherUserPredictionsPage(), // Instancie correctement la page
)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
