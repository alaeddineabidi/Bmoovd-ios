// lib/route_generator.dart

// ignore_for_file: unused_local_variable

import 'package:bmoovd/screens/notifications/notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case InvitationsPage.routeName:
        final message = settings.arguments as RemoteMessage;
        final arguments = settings.arguments as RemoteMessage?;

        return MaterialPageRoute(
          builder: (context) => InvitationsPage(message:message),
        );


      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR: Route not found!'),
        ),
      ),
    );
  }
}
