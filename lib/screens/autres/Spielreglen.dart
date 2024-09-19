import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpielregelnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Spielregeln',
            style: GoogleFonts.plusJakartaSans(
                color: Color(0xffE6E7E9), fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Image.asset("assets/icons/back_arrow.png")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wie funktioniert es?',
                style: GoogleFonts.plusJakartaSans(
                    color: Color(0xffCFCFCF), fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16),
              Text(
                'Alle Spiele können im Voraus getippt werden. Dafür muss der jeweilige Spieltag ausgewählt werden.\n'
                'Ihr könnt die Tipps vor dem Anpfiff so oft ändern wie Ihr möchtet. Nach dem Anpfiff ist dies nicht mehr möglich.\n'
                'Nachdem Ihr Eure Tipps eingetragen habt, müsst Ihr auf "Speichern" klicken. Im Anschluss bekommt Ihr eine Bestätigungsnachricht angezeigt.\n'
                'Gewonnen hat der Spieler mit den meisten Punkten innerhalb der Gesamttabelle (Spieltag & Saison). Sollten am Spieltage oder am Ende der Saison mehrere Tipper die gleiche Punktanzahl haben, entscheidet das Los.\n'
                'Der Gewinn ist weder austausch-, noch auf Dritte übertragbar. Sachgewinne können nicht in bar ausgezahlt werden und sind vom Umtausch ausgeschlossen.\n'
                'Es zählt das Endergebnis nach Verlängerung und Elfmeterschießen',
                style: GoogleFonts.plusJakartaSans(
                    color: Color(0xffE6E7E9), fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
