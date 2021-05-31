import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/inputFields.dart';

import 'Alerts/all_alerts.dart';
import 'AuthScreens/SignInPage.dart';
import 'Constants/urls.dart';
import 'helpers/apiClient.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool isLoadinglogout;

  _clearPreferences() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.clear();
  }

  _logout() async {
    try {
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.LOGOUT,
          authHeader: true,
          httpMethod: HTTPMethod.POST,
          context: context);
      if (response.data["response"] == "Logout Successful") {
        Alerts().showAlertDialog(response.data["response"]);
        _clearPreferences();
        Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
                child: SignInPage(), type: PageTransitionType.bottomToTop),
            (route) => false);
      } else {
        Alerts().showAlertDialog("Some Error Occurred!");
      }
    } catch (e) {
      print(e.toString());
      Alerts().showAlertDialog("Some Error Occurred!");
    } finally {
      setState(() {
        isLoadinglogout = false;
      });
    }
  }

  _showLogoutDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Are you sure you want to Logout?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      isLoadinglogout = true;
                    });
                    _logout();
                  },
                  child: Text("Yes")),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("No"),
              )
            ],
          );
        });
  }

  _getProfileDetails() async {}

  @override
  void initState() {
    _getProfileDetails();
    isLoadinglogout = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              ClipPath(
                clipper: CurveClipper(),
                child: Container(
                  height: screenSize.height * 0.18,
                  color: primaryColor,
                ),
              ),
              SizedBox(
                height: 100.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: frugoProfileField("Email"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: frugoProfileField("Full Name"),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: primaryColor),
                  onPressed: () {
                    //_clearPreferences();
                    if (!isLoadinglogout) _showLogoutDialog();
                  },
                  child: (isLoadinglogout)
                      ? Container(
                          width: 50.0,
                          child: SpinKitThreeBounce(
                            size: 15.0,
                            color: Colors.white,
                          ),
                        )
                      : Text("Logout?")),
            ],
          ),
          Positioned(
            child: Container(
              height: 160.0,
              width: 160.0,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                  border: Border.all(color: Colors.white, width: 7.0)),
              child: Icon(
                Icons.person,
                size: 50.0,
              ),
            ),
            top: screenSize.height * 0.18 - 80.0,
            left: screenSize.width * 0.5 - 80.0,
          ),
        ],
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    int curveHeight = 40;
    Offset controlPoint = Offset(size.width / 2, size.height + curveHeight);
    Offset endPoint = Offset(size.width, size.height - curveHeight);

    Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
