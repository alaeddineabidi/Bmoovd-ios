import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionNotif extends StatefulWidget {
  @override
  _PermissionNotifState createState() => _PermissionNotifState();
}

class _PermissionNotifState extends State<PermissionNotif> {
  bool isNotificationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  // Überprüfen Sie den Status der Benachrichtigungsberechtigung
  Future<void> _checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    setState(() {
      isNotificationEnabled = status.isGranted;
    });
  }

  // Benachrichtigungsberechtigung anfordern
  Future<void> _toggleNotificationPermission() async {
    if (isNotificationEnabled) {
      // Benachrichtigungen deaktivieren (direkt in Flutter nicht möglich, nur für die UI)
      setState(() {
        isNotificationEnabled = false;
      });
    } else {
      PermissionStatus status = await Permission.notification.request();
      setState(() {
        isNotificationEnabled = status.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Benachrichtigungen',
            style: GoogleFonts.plusJakartaSans(
              color: Color(0xffE6E7E9),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset("assets/icons/back_arrow.png"),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Center(
              child: Text(
                "Passen Sie Ihre Benachrichtigungen nach Ihren Wünschen an.",
                style: GoogleFonts.plusJakartaSans(
                  color: Color(0xffB3B3B3),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xff1A1C20),
                border: Border.all(
                  width: 0.85,
                  color: Color.fromRGBO(230, 231, 233, 0.50),
                ),
              ),
              padding: EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationItem('Nachrichten', 'Sport- und Wirtschaftsnachrichten'),
                  _buildNotificationItem('Live-Ergebnisse', 'Live-Sport-Ergebnisse'),
                  _buildNotificationItem('Spiel', 'Spielaktualisierungen und Nachrichten'),
                  _buildNotificationItem('Aktivitäten', 'Verfolgen Sie Ihre Aktivitäten'),
                  _buildNotificationItem('Gutscheine', 'Sonderangebote und Gutscheine'),
                ],
              ),
            ),
          ),
          SwitchListTile(
            title: Text(
              'Benachrichtigungen aktivieren',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Benachrichtigungsberechtigungen umschalten',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            value: isNotificationEnabled,
            onChanged: (bool value) {
              _toggleNotificationPermission();
            },
            activeColor: Colors.teal,
            inactiveTrackColor: Colors.grey,
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          description,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.0,
            color: Colors.grey[400],
          ),
        ),
        SizedBox(height: 8.0),
        Divider(
          color: Colors.grey[600],
          thickness: 1.0,
        ),
        SizedBox(height: 8.0),
      ],
    );
  }
}
