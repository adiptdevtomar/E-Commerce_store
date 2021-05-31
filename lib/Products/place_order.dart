import "package:flutter/material.dart";
import 'package:spike_demo/Alerts/all_alerts.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/urls.dart';
import 'package:spike_demo/helpers/apiClient.dart';
import 'package:spike_demo/Constants/globals.dart' as globals;

class PlaceOrder extends StatefulWidget {
  @override
  _PlaceOrderState createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  bool isLoading = false;
  bool isPlaced = false;

  _placeOrder() async {
    setState(() {
      isLoading = true;
    });
    var reqBody = {"cart_id": globals.cartId};
    try {
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.PLACE_ORDER,
          httpMethod: HTTPMethod.POST,
          authHeader: false,
          requestBody: reqBody,
          context: context);
      if (response.data["message"] == "Order PLaced Successfully") {
        setState(() {
          isPlaced = true;
        });
      } else {
        Alerts().showAlertDialog("Error Occurred!");
      }
    } catch (e) {
      print(e.toString());
      Alerts().showAlertDialog("Error Occurred!");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget loadingWidget() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.85),
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 100.0),
            child: Text(
              "Placing Order...",
              style: TextStyle(color: Colors.white, fontSize: 40.0),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: (isPlaced)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Icon(
                        Icons.done,
                        size: 100.0,
                      ),
                      height: 130.0,
                      width: 130.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 10.0)),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Center(
                        child: Text(
                      "Order Placed\nSuccessfully!",
                      style: TextStyle(fontSize: 30.0),
                    )),
                    SizedBox(
                      height: 30.0,
                    ),
                    TextButton(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 40.0, vertical: 10.0),
                        child: Text(
                          "<- Continue Shopping",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        backgroundColor: primaryColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                )
              : Center(
                  child: TextButton(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 10.0),
                      child: Text(
                        "Pay Now",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      backgroundColor: primaryColor,
                    ),
                    onPressed: () {
                      _placeOrder();
                    },
                  ),
                ),
        ),
        IgnorePointer(
          ignoring: true,
          child: AnimatedCrossFade(
              firstChild: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
              secondChild: loadingWidget(),
              crossFadeState: !isLoading
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 500)),
        ),
      ],
    );
  }
}
