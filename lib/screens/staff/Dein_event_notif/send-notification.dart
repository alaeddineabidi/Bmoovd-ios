import 'dart:convert';
import 'package:bmoovd/constant/apiConfig/api-header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class NotificationSend extends StatelessWidget{

 Future<void> _sendNotificationToAllUsers() async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final usersSnapshot = await usersCollection.get();

    for (var userDoc in usersSnapshot.docs) {
      final userData = userDoc.data();
      final fcmToken = userData['fcmToken'];

      if (fcmToken != null) {
        await _sendNotification(fcmToken);
      }
    }
  }

  Future<void> _sendNotification(String fcmToken) async {
    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/bmoovddatabase/messages:send');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${ApiConfig.accessToken}', // Replace with your actual access token
    };
    
    // Correct the payload by changing "notifications" to "notification"
    final notification = {
     "message":{
        "token":fcmToken,
        "notification":{ // Use "notification" instead of "notifications"
          "title":"newNotification",
          "body":"new"
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
      body:Center(
        child: ElevatedButton(onPressed: () async {

         _sendNotificationToAllUsers();
         print("done");
        }, child: Container(
          child: Text("click here to send notifications to all users"),
        )),
      ),
    );
  }
}