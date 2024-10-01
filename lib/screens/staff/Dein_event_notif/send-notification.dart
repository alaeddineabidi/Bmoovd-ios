import 'dart:convert';
import 'package:bmoovd/ClientApi/FirebaseService/access_firebase_token.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationSend extends StatefulWidget {
  @override
  _NotificationSendState createState() => _NotificationSendState();
}

class _NotificationSendState extends State<NotificationSend> {
  bool isLoading = false;
  String statusMessage = '';
  String? accessToken;

  Future<void> _sendNotificationToAllUsers() async {
    setState(() {
      isLoading = true;
      statusMessage = 'Sending notifications...';
    });

    // Fetch the access token outside setState
    final fetchedAccessToken = await AccessTokenFirebase.getAccessToken();

    final usersCollection = FirebaseFirestore.instance.collection('users');
    final usersSnapshot = await usersCollection.get();

    for (var userDoc in usersSnapshot.docs) {
      final userData = userDoc.data();
      final fcmToken = userData['fcmToken'];

      if (fcmToken != null) {
        await _sendNotification(fcmToken, fetchedAccessToken);
      }
    }

    // Now update the state once all notifications are sent
    setState(() {
      isLoading = false;
      statusMessage = 'Notifications sent successfully!';
      accessToken = fetchedAccessToken; // Save the access token to state
    });
  }

  Future<void> _sendNotification(String fcmToken, String? accessToken) async {
    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/bmoovddatabase/messages:send');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken', // Use the fetched access token
    };

    final notification = {
      "message": {
        "token": fcmToken,
        "notification": {
          "title": "Neue Benachrichtigung", // German for "newNotification"
          "body": "Dein Event steht an!"    // German for "Your event is coming up!"
        }
      }
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(notification),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Code: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      await _sendNotificationToAllUsers();
                    },
                    child: Text("Click here to send notifications to all users"),
                  ),
            SizedBox(height: 20),
            Text(statusMessage),
          ],
        ),
      ),
    );
  }
}
