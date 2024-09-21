import 'dart:convert';
import 'package:bmoovd/screens/game/PlayedMatch.dart';
import 'package:bmoovd/screens/game/ordred_users_point.dart';
import 'package:bmoovd/widgets/BottomNavigationBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bmoovd/ClientApi/footballApi/football.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Predictionscore extends StatefulWidget {
  @override
  _PredictionscoreState createState() => _PredictionscoreState();
}
class _PredictionscoreState extends State<Predictionscore> {
    bool isExpanded = false;
    bool showAllUsers = true;
    Map<String, dynamic>? currentLeague;
     Future<void> fetchData() async {
    final data = await ApiServiceFootball.fetchCurrentLeague();
    setState(() {
      currentLeague = data;
    });
    print("current league $currentLeague");
  }


  List<dynamic>? matchData;
  Map<String, Map<String, dynamic>> oddsData = {}; 
    Map<int, bool> expandedStates = {}; 
    void _toggleExpand(int matchId) {
    setState(() {
      if (expandedStates.containsKey(matchId)) {
        expandedStates[matchId] = !expandedStates[matchId]!; // Inverser l'état d'expansion
      } else {
        // Réinitialiser les autres cartes
        expandedStates = {for (var id in expandedStates.keys) id: false};
        expandedStates[matchId] = true; // Étendre la carte cliquée
      }
    });
  }
   int? points;
  Future<void> _fetchUserName() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid; // Get current user's ID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      setState(() {
        points = userDoc['points'];
      });
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  Future<void> fetchAndPrintApiData() async {
    final url = Uri.parse(
        'https://pinnacle-odds.p.rapidapi.com/kit/v1/markets?sport_id=1&is_have_odds=true&league_ids=1842');

    final headers = {
      'x-rapidapi-host': 'pinnacle-odds.p.rapidapi.com',
      'x-rapidapi-key': '3114569301msh072f3dd97499e26p18aeb6jsne3c5eb8e18db'
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data');

        if (data['events'] != null) {
          for (var event in data['events']) {
            final odds = event['periods']['num_0']['money_line'] ?? {};

            final homeTeamName = (event['home'] ?? '').toLowerCase().trim();
            final awayTeamName = (event['away'] ?? '').toLowerCase().trim();
            final key = '$homeTeamName-$awayTeamName';  // Create a normalized key

            oddsData[key] = {
              'homeTeam': homeTeamName,
              'awayTeam': awayTeamName,
              'homeOdds': double.tryParse(odds['home'].toString()) ?? 0.0,
              'drawOdds': double.tryParse(odds['draw'].toString()) ?? 0.0,
              'awayOdds': double.tryParse(odds['away'].toString()) ?? 0.0,
            };
          }
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
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

  Future<void> loadMatchDetails() async {
    try {
      final data = await ApiServiceFootball.fetchMatchDetailsNS();
      if (data != null) {
        setState(() {
          matchData = data;
        });

        print("Not Started match: $matchData");
      }
    } catch (e) {
      print("Error loading match details or odds: $e");
    }
  }

  String normalizeName(String name) {
    return name.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
  }

  bool isMatch(String name1, String name2) {
    final normalized1 = normalizeName(name1);
    final normalized2 = normalizeName(name2);

    return normalized1.contains(normalized2) || normalized2.contains(normalized1);
  }

  @override
  void initState() {
    super.initState();
    fetchAndPrintApiData();
    loadMatchDetails();
    _fetchUserName();
    fetchData();
    
  }

 
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tippspiel',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700,fontSize:16,color:Color(0xFFCFCFCF)),
        ),
        actions: [
          IconButton(
            icon: Image.asset("assets/icons/Chart.png"), 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LeaderboardPage()), // Remplacez FootballPage par la page souhaitée
              );
            },
          ),
        ],
      ),
      body: matchData == null
          ? Center(child: CircularProgressIndicator(color: Color(0xFF91306A),))
          : Column(
                crossAxisAlignment: CrossAxisAlignment.start,

            
            children: [
               Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),),
                  child: Container(
  height: 122,
  decoration: BoxDecoration(
    border: Border.all(width: 0.1, color: Color(0xFFE6E7E9)),
    borderRadius: BorderRadius.circular(8),
    gradient: const RadialGradient(
      center: Alignment(0.0851, -0.2418), // Alignement équivalent aux valeurs CSS
      radius: 2.377, // La valeur de votre rayon
      colors: [
        Color.fromRGBO(49, 58, 91, 0.10), // Couleur avec opacité
        Color(0xFF21273D), // Couleur finale
      ],
      stops: [0.302, 1.0], // Positionnement des couleurs dans le gradient
    ),
  ),
  child: InkWell(
    onTap: (){
      Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlayedMatches()), // Remplacez FootballPage par la page souhaitée
              );
    },
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Aligner le texte à gauche
            mainAxisAlignment: MainAxisAlignment.center, // Centrer verticalement
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10),
                child: Text(
                  "Gespielte spiele",
                  style: GoogleFonts.plusJakartaSans(
                    color: Color(0xFFE6E7E9),
                    fontSize: 12.8,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left, // Aligner le texte à gauche
                ),
              ),
              SizedBox(height: 5), // Espace entre les textes
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Klicken Sie hier, um die Spiele anzuzeigen, die Sie kürzlich gespielt haben.",
                  style: GoogleFonts.plusJakartaSans(
                    color: Color(0xFFB3B3B3), // Couleur de texte
                    fontSize: 14,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.left, // Aligner le texte à gauche
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Image.asset(
            "assets/images/clock.png",
            width: double.infinity, // Assure que l'image occupe toute la largeur
            height: 123, // Ajuste la hauteur pour correspondre au bouton
            fit: BoxFit.cover, // Ajuste l'image pour qu'elle couvre la zone disponible
          ),
        ),
      ],
    ),
  ),
),


                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                                  color: Color(0xff7D8B92),
                                  thickness: 1.0,
                                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:15.0),
                    child: Text("Kommende Spiele",style: GoogleFonts.plusJakartaSans(color:Color(0xffCFCFCF),fontSize:16,fontWeight: FontWeight.w700),textAlign: TextAlign.start,),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right:20.0),
                    child: Text("$points Points",style:GoogleFonts.plusJakartaSans()),
                  )
                ],
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: matchData!.length,
                    itemBuilder: (context, index) {
                      int homeScore = 0;
                      int awayScore = 0;
                      final match = matchData![index];
                      final matchStatus = match["fixture"]["status"]["long"];
                      final matchIdSTR = match["fixture"]["id"].toString();
                      final matchId = match["fixture"]["id"];
                      final homeTeam = match['teams']['home'] ?? {};
                      final awayTeam = match['teams']['away'] ?? {};
                      final homeTeamName = homeTeam['name'] ?? 'unknown';
                      final awayTeamName = awayTeam['name'] ?? 'unknown';
                      final key = '$homeTeamName-$awayTeamName';
                      var isExpanded = expandedStates[matchId] ?? false;
                      print('Checking odds for key: $key');  
                      final odds = oddsData.entries.firstWhere(
                        (entry) => isMatch(homeTeamName, entry.value['homeTeam']) &&
                                  isMatch(awayTeamName, entry.value['awayTeam']),
                        orElse: () => const MapEntry('', { 
                          'homeTeam': '',
                          'awayTeam': '',
                          'homeOdds': 0.0,
                          'drawOdds': 0.0,
                          'awayOdds': 0.0,
                        }),
                      ).value; 
                      final hasOdds = odds['homeOdds'] != 0.0 || odds['drawOdds'] != 0.0 || odds['awayOdds'] != 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        
                          child: GestureDetector(
                            onTap: () {
                            _toggleExpand(matchId);
                               },
                            child: AnimatedContainer(
                              
                              decoration: BoxDecoration(border :Border.all(
                                  style: BorderStyle.solid,
                                  color: Color.fromRGBO(230, 231, 233, 0.50), // Couleur de la bordure
                                  width: 0.85,         // Épaisseur de la bordure
                                ),
                                borderRadius:BorderRadius.circular(8),
                                color: Color(0xff1A1C20), ),
                             
                                
                              height: isExpanded ? 309 :150,
                              
                              duration: Duration(milliseconds:0 ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(_formatMatchDate(match['fixture']['date']),style:GoogleFonts.plusJakartaSans(color:Color(0xffB3B3B3),fontSize: 14,fontWeight: FontWeight.w400)),
                                        Text("—",style:GoogleFonts.plusJakartaSans(color:Color(0xffB3B3B3),fontSize: 14,fontWeight: FontWeight.w400)),
                                        Text(_formatMatchTime(match['fixture']['date']),style:GoogleFonts.plusJakartaSans(color:Color(0xffB3B3B3),fontSize: 14,fontWeight: FontWeight.w400)),
                                        Text("—",style:GoogleFonts.plusJakartaSans(color:Color(0xffB3B3B3),fontSize: 14,fontWeight: FontWeight.w400)),
                                        Text("${match["fixture"]["venue"]["city"]}",style:GoogleFonts.plusJakartaSans(color:Color(0xffB3B3B3),fontSize: 14,fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                    SizedBox(height: 10,),
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
                                            homeTeamName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis, 
                                            maxLines: 1, 
                                          ),
                                        ),
                                        Spacer(),
                                        Flexible(
                                          child: Text(
                                            awayTeamName,
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
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                       Text("Quoten",style:GoogleFonts.plusJakartaSans(color:Color(0xffB3B3B3),fontSize: 14,fontWeight: FontWeight.w400)),
                                        Container(
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),border: Border.all(color: Color.fromRGBO(230, 231, 233, 0.50),)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              hasOdds
                                                ? '${odds['homeOdds']} / ${odds['drawOdds']} / ${odds['awayOdds']}'
                                                : 'Keine Quoten verfügbar.',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                color: hasOdds ? Color(0xff80BDBD) : Colors.red,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isExpanded) ...[
                                      const SizedBox(height: 10,),
                                      Text(
                                        "Eine vorhersage machen",
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Color(0xffE6E7E9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                        
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                    padding: const EdgeInsets.only(right: 60.0, left: 60, top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 43,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          fillColor: Color(0xff15161A),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 2,
                                              color: Color.fromRGBO(230, 231, 233, 0.50),
                                            ),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 2,
                                              color: Color.fromRGBO(230, 231, 233, 0.50),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 2,
                                              color: Color.fromRGBO(230, 231, 233, 0.50),
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 2,
                                              color: Color.fromRGBO(230, 231, 233, 0.50),
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                              homeScore = int.tryParse(value) ?? 0;
                                            },
                                      ),
                                    ),
                                    Text("—"),
                                    SizedBox(
                                      width: 43,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          fillColor: Color(0xff15161A),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 2,
                                              color: Color.fromRGBO(230, 231, 233, 0.50),
                                            ),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 2,
                                              color: Color.fromRGBO(230, 231, 233, 0.50),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 2,
                                              color: Color.fromRGBO(230, 231, 233, 0.50),
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              width: 2,
                                              color: Color.fromRGBO(230, 231, 233, 0.50),
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                              awayScore = int.tryParse(value) ?? 0;
                                            },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                                    const SizedBox(height: 10),
                                    Container(
                              width: double.infinity, // Le container prend toute la largeur disponible
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width / 2 - 5, // Prend la moitié de l'écran moins l'espace
                                      child: ElevatedButton(
                                        onPressed: () {
                                        },
                                        style: ElevatedButton.styleFrom(
                                          
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: BorderSide(color:Color.fromRGBO(230, 231, 233, 0.50),width: 0.85 ) // Ajuster le borderRadius ici
                                          ),
                                        ),
                                        child: Text("Storieren",style:GoogleFonts.plusJakartaSans(color: Color(0xFFE6E7E9),fontSize:14,fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10), // Espace de 10 pixels entre les boutons
                                  Expanded(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width / 2 - 5, // Prend la moitié de l'écran moins l'espace
                                      child: ElevatedButton(
                                        onPressed: () {
                                          ApiServiceFootball.submitPrediction(
                                              context,
                                              matchIdSTR,
                                              homeScore,
                                              awayScore,
                                              matchStatus,
                                            );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Color.fromRGBO(0, 124, 124, 0.60),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: BorderSide(color:Color.fromRGBO(0, 124, 124, 0.60),width: 0.85 ) // Ajuster le borderRadius ici
                                          ),
                                        ),
                                        child: Text("vorhersagen",style:GoogleFonts.plusJakartaSans(color: Color(0xFFE6E7E9),fontSize:14,fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )

                                  ],
                                ),
                            ]
                         ],
                                ),
                              ),
                            ),
                          ),
                        
                      );
                    },
                  ),
              ),
            ],
          ),
                 bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 2, context: context,)

    );
  }
}

