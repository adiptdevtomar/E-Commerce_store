import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:spike_demo/SplashScreen.dart';
import 'package:spike_demo/add_category.dart';
import 'package:spike_demo/Constants/globals.dart' as globals;

import 'AuthScreens/SignInPage.dart';
import 'AuthScreens/SignUpPage.dart';
import 'Products/Dashboard.dart';
import 'Products/ProductPage.dart';

/*Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}*/

Future<void> main() async {
  /*WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getToken();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);*/

  try {
    WidgetsFlutterBinding.ensureInitialized();
    globals.cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e.toString());
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: SplashScreen(),//HomePage(pageTitle: "Welcome"),
      routes: <String, WidgetBuilder> {
        '/signup': (BuildContext context) =>  SignUpPage(),
        '/signin': (BuildContext context) =>  SignInPage(),
        '/dashboard': (BuildContext context) => Dashboard(),
        '/productPage': (BuildContext context) => ProductPage(),
        '/addCategory': (BuildContext context) => AddCategory(),
      },
    );
  }
}
