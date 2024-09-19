import 'package:bmoovd/ClientApi/footballApi/football.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class MatchDetailsPage extends StatefulWidget {
  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  List<dynamic>? matchData;

  @override
  void initState() {
    super.initState();
    loadMatchDetails();
  }

  Future<void> loadMatchDetails() async {
    final data = await ApiServiceFootball.fetchMatchDetails();
    setState(() {
      matchData = data;
      
    });
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Live-Spiele', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700,color: Color(0xffE6E7E9),fontSize: 16))),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset("assets/icons/back_arrow.png"),
        ),
      ),
      body: matchData == null
          ? Center(child: CircularProgressIndicator(color: Colors.teal,))
          : ListView.builder(
              itemCount: matchData!.length,
              itemBuilder: (context, index) {
                final match = matchData![index];
                final homeTeam = match['teams']['home'] ?? {};
                final awayTeam = match['teams']['away'] ?? {};
                final status = match["fixture"]['status'] ?? {};
                final score = match['score'] ?? {};
                final halftime = score['halftime'] ?? {};
                final elapsed = status['elapsed'] ?? 0;

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
      color: Colors.grey[900],  // Matching the color of the first container
    ),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  '${homeTeam['name'] ?? 'Unknown'}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Spacer(),
              Expanded(
                child: Text(
                  '${awayTeam['name'] ?? 'Unknown'}',
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
              Text(
                'Status: ${status['long'] ?? 'Unknown'}',
                style: GoogleFonts.poppins(
                  color: Colors.grey[400],
                ),
              ),
              Text(
                'Time Elapsed: ${elapsed}\'',
                style: GoogleFonts.poppins(
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            'Score: ${halftime['home'] ?? 0} - ${halftime['away'] ?? 0}',
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    ),
  ),
);

              },
            ),
    );
  }
}