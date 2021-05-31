import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_demo/Constants/globals.dart' as globals;

import 'package:spike_demo/Constants/urls.dart';
import 'InternetException.dart';
import 'debugLogger.dart';

enum HTTPMethod { GET, POST }

class ApiAdapter {
  var _headers = {
    "Accept": "application/json",
    "Content-Type": "application/x-www-form-urlencoded"
  };

  static String _deviceIdentity;

  static ApiAdapter getInstance() {
    return new ApiAdapter();
  }

  Future<ApiResponse> callAPI(
      {@required String reqUrl,
        @required HTTPMethod httpMethod,
        @required BuildContext context,
        dynamic requestBody,
        bool authHeader = false,
        bool doRetryOnError = true,
        bool isFullUrl = false,
        bool shouldLogout = true}) async {
    globals.isInternet = await isNetworkConnected();
    var responseBody;

    String surl = Urls.BASE_URL + reqUrl;
    Uri url = Uri.parse(surl);

    SharedPreferences _prefs = await SharedPreferences.getInstance();

    print(
        '${DateFormat.yMd().add_Hms().format(DateTime.now())} - [Request]  \n\t\t\t\t\t\tURL: \t$url \n\t\t\t\t\t\tMethod : \t$httpMethod  \n\t\t\t\t\t\tData : \t$requestBody');
    try {
      if (globals.isInternet) {
        final ioc = new HttpClient();
        ioc.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        final http = new IOClient(ioc);
        var response;
        _headers = {
          "Accept": "application/json",
          "Content-Type": "application/json",
          // "Content-Type": "application/x-www-form-urlencoded"
        };
        if (authHeader) {
          _headers['Authorization'] =
              "Token " + _prefs.getString("token");
        }
        print(_headers);
        switch (httpMethod) {
          case HTTPMethod.POST:
            response = await http
                .post(url,
                headers: _headers,
                body: jsonEncode(requestBody),
                encoding: Encoding.getByName('utf-8'))
                .timeout(const Duration(seconds: 60));
            break;

          case HTTPMethod.GET:
            response = await http
                .get(url, headers: _headers)
                .timeout(const Duration(seconds: 60));
            break;
        }

        responseBody = response.body;
        debugLog('[Response] $reqUrl $responseBody');
        responseBody = ApiResponse(responseBody);
        /*if (responseBody.data["statusCode"] == "403" && shouldLogout) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.clear();
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context)
              .pushReplacementNamed(Routes.PAGE_VIEW_TRANSITION);
          Fluttertoast.showToast(
              msg: "Logged out.",
              backgroundColor: Colors.grey,
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT);
        }*/
        // print("Response Code : ${response.statusCode}");
        // if (response.statusCode == 200) {
        //   // responseBody = response.body;
        // }
        // else if (response.statusCode == 401) {
        //   //todo logout

        // }
        // else {
        //   throw CustomException(
        //       'In api_client.callAPI() : Unhandled Http response code (StatusCode=${response.statusCode}) in $url');
        // }
      } else {

        throw NoInternetException(
            'In api_client.callAPI() : No Internet Connection calling $url');
      }
    } on TimeoutException {
      throw NoInternetException(
          'In api_client.callAPI() : No Internet Connection calling $url');
    }
    // catch (e) {
    //   debugLog('[Exception] $e');
    //   throw CustomException(e.toString());
    // }
    return responseBody == null ? null : responseBody;
  }

  static Future<bool> isNetworkConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {}
    return false;
  }

}

class ApiResponse {
  bool success;
  String error;
  dynamic data;

  ApiResponse(String responseBody) {
    var decoded = json.decode(responseBody);
    if (decoded == null) {
      success = false;
      return;
    }
    if (decoded is Map && decoded['status'] == "ERROR") {
      success = false;
      error = decoded["message"] ?? decoded["Message"] ?? "Unknown Error";
    } else {
      success = true;
    }
    data = decoded;
  }

  @override
  String toString() {
    return success
    // ? {"success": success, "data": data}.toString()
        ? {"success": success}.toString()
        : {"error": error}.toString();
  }
}
