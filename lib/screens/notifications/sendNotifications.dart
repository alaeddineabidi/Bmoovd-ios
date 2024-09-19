import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String serverKey = 'YOUR_SERVER_KEY';

  static Future<void> sendNotification(String fcmToken, String notificationTitle, String notificationBody) async {
    try {
      final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      };

      final notification = {
        'title': notificationTitle,
        'body': notificationBody,
      };

      final data = {
        'to': fcmToken,
        'notification': notification,
        'priority': 'high',
      };
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        print('Notification envoyée avec succès');
      } else {
        print('Échec de l\'envoi de la notification. Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification: $e');
    }
  }
}