import 'package:bmoovd/main.dart';
import 'package:bmoovd/screens/notifications/notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class Firebasenotifications {

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications()async{
    await _firebaseMessaging.requestPermission();
    String? token = await _firebaseMessaging.getToken();
    print(token);
  }

  void handleMessaging(RemoteMessage? message){
    if (message==null){
      return;
    }
    navigatorKey.currentState!.pushNamed(InvitationsPage.routeName,arguments : message);


    Future HandleBackgroundNotifications()async{
      FirebaseMessaging.instance.getInitialMessage().then(handleMessaging);
      FirebaseMessaging.onMessageOpenedApp.listen(handleMessaging);
    }
  }
}