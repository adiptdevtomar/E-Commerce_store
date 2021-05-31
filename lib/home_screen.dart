/*
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String messageTitle = "Empty";
  String notificationAlert = "alert";

  FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    _firebaseMessaging = FirebaseMessaging.instance;
    print("in");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message Received");
      print(message.notification.title);
      print(message.notification.body);
      setState(() {
        messageTitle = message.notification.title;
        notificationAlert = message.notification.body;
      });
    });

    */
/*FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

    });*//*

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Push Notification"),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              messageTitle,
              style: Theme.of(context).textTheme.headline3,
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              notificationAlert,
              style: Theme.of(context).textTheme.headline6,
            )
          ],
        ),
      ),
    );
  }
}
*/
