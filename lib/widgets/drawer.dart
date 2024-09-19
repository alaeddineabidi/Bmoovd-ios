import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Image.asset("assets/logo/bmoovd_wortmarke_subline_wht.png"),
          ),
          ListTile(
            title: Text('Home', style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () {},
          ),
          ExpansionTile(
            title: Text('SPORTSBAR', style: GoogleFonts.poppins(color: Colors.white)),
            children: <Widget>[
              ListTile(
                title: Text('LIVEEVENTS', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                title: Text('RUCKBLICK', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
            ],
          ),
          ListTile(
            title: Text('EAT & DRINK', style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () {},
          ),
          ExpansionTile(
            title: Text('BOWLING', style: GoogleFonts.poppins(color: Colors.white)),
            children: <Widget>[
              ListTile(
                title: Text('VIP LOGE', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                title: Text('BOWLING LIGA', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                title: Text('GEBURTSTAG', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
            ],
          ),
          ExpansionTile(
            title: Text('ACTIVITIES', style: GoogleFonts.poppins(color: Colors.white)),
            children: <Widget>[
              ListTile(
                title: Text('MULTISPORT SIMULATOR', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                title: Text('DARTS', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                title: Text('FUN4FOUR', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
            ],
          ),
          ListTile(
            title: Text('DEIN EVENT', style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            title: Text('GUTSHEIN', style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () {},
          ),
          ExpansionTile(
            title: Text('UBER UNS', style: GoogleFonts.poppins(color: Colors.white)),
            children: <Widget>[
              ListTile(
                title: Text('HIER FINDEST DU UNS', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                title: Text('KOMM INS TEAM', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                title: Text('SO SIEHT\'S AUS', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}


