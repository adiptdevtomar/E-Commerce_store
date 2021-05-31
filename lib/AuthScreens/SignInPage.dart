import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_demo/Alerts/all_alerts.dart';
import 'package:spike_demo/Constants/styles.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/inputFields.dart';
import 'package:page_transition/page_transition.dart';
import 'package:spike_demo/AuthScreens/SignUpPage.dart';
import 'package:spike_demo/Constants/urls.dart';
import 'package:spike_demo/helpers/apiClient.dart';
import '../Products/Dashboard.dart';
import 'package:spike_demo/Constants/globals.dart' as globals;

class SignInPage extends StatefulWidget {
  final String pageTitle;

  SignInPage({Key key, this.pageTitle}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _email;
  TextEditingController _password;
  String errorText;
  bool isLoading;

  bool validateEmail(email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  _storeToken(token, cartId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("token", token);
    preferences.setString("cart_id", cartId);
    globals.token = token;
    globals.cartId = cartId;
  }

  _login() async {
    setState(() {
      isLoading = !isLoading;
    });
    if (!isLoading) return;
    try {
      Map<String, dynamic> resBody = {
        "username": _email.text,
        "password": _password.text,
      };
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.LOGIN,
          requestBody: resBody,
          httpMethod: HTTPMethod.POST,
          context: context);
      if (response.data["user_id"] != null) {
        Alerts().showAlertDialog("Logged in Successfully");
        _storeToken(response.data["token"], response.data["cart_id"]);
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft, child: Dashboard()));
      }
      if (response.data["non_field_errors"] != null)
        Alerts().showAlertDialog("Incorrect email or password");
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    errorText = "";
    isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: white,
          title: Text('Sign In',
              style: TextStyle(
                  color: Colors.grey, fontFamily: 'Poppins', fontSize: 15)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: SignUpPage()));
              },
              child: Text('Sign Up', style: contrastText),
            )
          ],
        ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 18, right: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Welcome Back!', style: h3),
                  Text('Howdy, let\'s authenticate', style: taglineText),
                  frugoTextInput('Email', _email, false),
                  frugoTextInput('Password', _password, true),
                  SizedBox(
                    height: 4.0,
                  ),
                  (errorText != "")
                      ? Text(errorText,
                          style: taglineText.copyWith(color: Colors.red))
                      : SizedBox.shrink(),
                  TextButton(
                    onPressed: () {},
                    child: Text('Forgot Password?', style: contrastTextBold),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.all(13),
                      ),
                      onPressed: () {
                        if (_email.text.isEmpty || _password.text.isEmpty) {
                          setState(() {
                            errorText = "No field can be left Empty";
                          });
                        } else if (!validateEmail(_email.text)) {
                          setState(() {
                            errorText = "Email format is Incorrect";
                          });
                        } else {
                          setState(() {
                            errorText = "";
                            FocusScope.of(context).unfocus();
                            _login();
                          });
                        }
                      },
                      child: Container(
                        height: 25.0,
                        width: 25.0,
                        child: (isLoading)
                            ? SpinKitThreeBounce(
                          color: Colors.white,
                          size: 12.0,
                        )
                            : Icon(Icons.arrow_forward, color: white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  )
                ],
              ),
              width: double.infinity,
              decoration: authPlateDecoration,
            ),
          ],
        ));
  }
}
