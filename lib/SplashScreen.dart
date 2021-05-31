import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_demo/AuthScreens/SignInPage.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Products/Dashboard.dart';
import 'package:spike_demo/Constants/globals.dart' as globals;

import 'Constants/styles.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int flag = 1;

  _getPreferences() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if (_prefs.getString("token") == null) {
      flag = 0;
    }
    else{
      globals.cartId = _prefs.getString("cart_id");
      globals.token = _prefs.getString("token");
    }

    Future.delayed(Duration(seconds: 2), () {
      if (flag == 1) {
        Navigator.of(context).pop();
        Navigator.push(
            context,
            PageTransition(
                child: Dashboard(), type: PageTransitionType.rightToLeft));
      }
      else{
        Navigator.of(context).pop();
        Navigator.push(
            context,
            PageTransition(
                child: SignInPage(), type: PageTransitionType.rightToLeft));
      }
    });
  }

  @override
  void initState() {
    _getPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/welcome.png', width: 190, height: 190),
            Container(
              margin: EdgeInsets.only(bottom: 10, top: 0),
              child: Text('Frugo!', style: logoStyle),
            ),
            SizedBox(
              height: 40.0,
            ),
            SpinKitDoubleBounce(
              color: Colors.green,
              size: 40.0,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              "Loading...",
              style: taglineText,
            )
            /*TextButton(
            child: Text("Add Category"),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddCategory()));
            },
          ),*/
          ],
        ),
      ),
      backgroundColor: bgColor,
    );
  }
}
