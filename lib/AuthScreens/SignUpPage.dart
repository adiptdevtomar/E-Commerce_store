import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:spike_demo/Alerts/all_alerts.dart';
import 'package:spike_demo/Constants/styles.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/inputFields.dart';
import 'package:page_transition/page_transition.dart';
import 'package:spike_demo/Constants/urls.dart';
import 'package:spike_demo/helpers/apiClient.dart';
import 'SignInPage.dart';
import '../Products/Dashboard.dart';

class SignUpPage extends StatefulWidget {
  final String pageTitle;

  SignUpPage({Key key, this.pageTitle}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isLoading;

  TextEditingController _email;
  TextEditingController _fullName;
  TextEditingController _password1;
  TextEditingController _password2;
  String errorText;

  bool validateEmail(email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  _registerUser() async {
    setState(() {
      isLoading = !isLoading;
    });
    if (!isLoading) return;
    try {
      Map<String, dynamic> resBody = {
        "email": _email.text,
        "name": _fullName.text,
        "password": _password1.text,
      };
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.REGISTER,
          requestBody: resBody,
          httpMethod: HTTPMethod.POST,
          context: context);
      if (response.data["response"] != null) {
        Alerts().showAlertDialog("${response.data["response"]}");
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft, child: SignInPage()));
      }
      if (response.data["email"] != null)
        Alerts().showAlertDialog("${response.data["email"][0]}");
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
    _fullName = TextEditingController();
    _password1 = TextEditingController();
    _password2 = TextEditingController();
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
          title: Text('Sign Up',
              style: TextStyle(
                  color: Colors.grey, fontFamily: 'Poppins', fontSize: 15)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Navigator.of(context).pushReplacementNamed('/signin');
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: SignInPage()));
              },
              child: Text('Sign In', style: contrastText),
            )
          ],
        ),
        body: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 18, right: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Welcome to Frugo!', style: h3),
                  Text('Let\'s get started', style: taglineText),
                  frugoTextInput('Email', _email, false),
                  frugoTextInput('Full Name', _fullName, false),
                  frugoTextInput('Password', _password1, true),
                  Align(
                    child: Padding(
                      padding: EdgeInsets.only(top: 3.0),
                      child: Text(
                        "Must be of 8 characters",
                        style: TextStyle(fontSize: 10.0),
                      ),
                    ),
                    alignment: Alignment.centerRight,
                  ),
                  frugoTextInput('Re-Enter Password', _password2, true),
                  SizedBox(
                    height: 8.0,
                  ),
                  (errorText != "")?Text(errorText,
                      style: taglineText.copyWith(color: Colors.red)):SizedBox.shrink(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.all(13),
                        ),
                        onPressed: () {
                          if (_email.text.isEmpty ||
                              _fullName.text.isEmpty ||
                              _password1.text.isEmpty ||
                              _password2.text.isEmpty) {
                            setState(() {
                              errorText = "No field can be left Empty";
                            });
                          } else if (!validateEmail(_email.text)) {
                            setState(() {
                              errorText = "Email format is Incorrect";
                            });
                          } else if (_password1.text.length < 8) {
                            setState(() {
                              errorText = "Short Password.";
                            });
                          } else if (_password1.text != _password2.text) {
                            setState(() {
                              errorText = "Passwords don't match";
                            });
                          } else {
                            setState(() {
                              errorText = "";
                              FocusScope.of(context).unfocus();
                              _registerUser();
                            });
                          }
                          /*Navigator.pushReplacement(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: Dashboard()));*/
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
                        )),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                ],
              ),
              width: double.infinity,
              decoration: authPlateDecoration,
            ),
          ],
        ));
  }
}
