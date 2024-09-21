import 'dart:convert';
import 'package:bmoovd/constant/apiConfig/api-header.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static Future<void> sendNotification(String fcmToken, String notificationTitle, String notificationBody) async {
    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/bmoovddatabase/messages:send');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${ApiConfig.accessToken}',
    };
    final notification = {
     "message":{
        "token":fcmToken,
        "notifications":{
          "title":notificationTitle,
          "body":notificationBody
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
      print('Failed to send notification. Code: ${response.statusCode}');
    }
  }
}