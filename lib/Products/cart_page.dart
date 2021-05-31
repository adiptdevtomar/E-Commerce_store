import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spike_demo/Alerts/all_alerts.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/styles.dart';
import 'package:spike_demo/Constants/urls.dart';
import 'package:spike_demo/Products/place_order.dart';
import 'package:spike_demo/helpers/apiClient.dart';
import 'package:spike_demo/Constants/globals.dart' as globals;

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoadingCart;
  List<dynamic> cartItems;
  Map<dynamic, dynamic> cartDetails;

  _showLoadingDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return WillPopScope(
            // ignore: missing_return
            onWillPop: () {},
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              content: SpinKitThreeBounce(
                size: 14.0,
                color: primaryColor,
              ),
            ),
          );
        });
  }

  _showDialog(productId) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Are you sure you want to remove this item?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteCartItem(productId);
                  },
                  child: Text("Yes")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),
            ],
          );
        });
  }

  _deleteCartItem(productId) async {
    _showLoadingDialog();
    try {
      var reqBody = {"cart": globals.cartId, "product": productId};
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.REMOVE_ITEM_FROM_CART,
          httpMethod: HTTPMethod.POST,
          authHeader: false,
          requestBody: reqBody,
          context: context);
      if (response.data["message"] != null) {
        Alerts().showAlertDialog(response.data["message"]);
        _getCartItems();
      } else {
        Alerts().showAlertDialog("An Error Occurred");
      }
      print(response.data);
    } catch (e) {
      print(e.toString());
      Alerts().showAlertDialog("An Error Occurred");
    } finally {
      Navigator.pop(context);
    }
  }

  _getCartItems() async {
    setState(() {
      isLoadingCart = true;
    });
    try {
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.GET_CART_ITEMS + globals.cartId,
          httpMethod: HTTPMethod.GET,
          authHeader: false,
          context: context);
      cartItems = response.data["cart_items"] ?? [];
      cartDetails = response.data;
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoadingCart = false;
      });
    }
  }

  @override
  void initState() {
    cartItems = [];
    isLoadingCart = true;
    _getCartItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    Widget cartItemTile(items) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.0),
        child: Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 2.0,
          child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
            height: screenSize.height * 0.13,
            child: Row(
              children: [
                Image.network(
                  items["image"],
                  width: screenSize.width * 0.22,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items["name"],
                              style: foodNameText.copyWith(
                                  fontSize: 18.0, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              "Quantity: " + items["quantity"].toString(),
                              style: h6.copyWith(fontSize: 13.0),
                            ),
                            Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text("₹ " + items["price"],
                                  style: h3.copyWith(fontSize: 20.0)),
                            )
                          ],
                        ),
                        Positioned(
                          child: GestureDetector(
                            onTap: () {
                              _showDialog(items["id"]);
                            },
                            child: Icon(
                              Icons.delete,
                              size: 20.0,
                              color: Colors.red,
                            ),
                          ),
                          right: 0.0,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 13.0),
        child: (isLoadingCart)
            ? Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: SpinKitThreeBounce(color: primaryColor, size: 17.0),
              )
            : ListView(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 15, top: 10),
                    child: Text("Cart", style: h4.copyWith(fontSize: 25.0)),
                  ),
                  (cartItems.length == 0)
                      ? Padding(
                          child: Text("No Item Added", style: taglineText),
                          padding: EdgeInsets.only(left: 15.0),
                        )
                      : ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            return cartItemTile(cartItems[index]);
                          },
                        ),
                  (cartItems.length != 0)
                      ? Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Divider(
                            color: Colors.grey.shade300,
                          ),
                        )
                      : SizedBox(),
                  (cartItems.length != 0)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Subtotal", style: h4),
                            Text(
                              "₹" + cartDetails["subtotal"],
                              style: h4.copyWith(fontSize: 18),
                            )
                          ],
                        )
                      : SizedBox(),
                  (cartItems.length != 0)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Tax", style: h6),
                            Text(
                              "+ ₹" + cartDetails["tax_amount"],
                              style: h6.copyWith(fontSize: 18),
                            )
                          ],
                        )
                      : SizedBox(),
                  (cartItems.length != 0)
                      ? Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Divider(
                            color: Colors.grey.shade300,
                          ),
                        )
                      : SizedBox(),
                  (cartItems.length != 0)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total", style: h4),
                            Text(
                              "₹" + cartDetails["total"],
                              style: h4.copyWith(fontSize: 18),
                            )
                          ],
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 15.0,
                  ),
                  (cartItems.length != 0)
                      ? TextButton(
                          onPressed: () {
                            Navigator.push(
                                    context,
                                    PageTransition(
                                        child: PlaceOrder(),
                                        type: PageTransitionType.rightToLeft))
                                .then((value) {
                              _getCartItems();
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                              "Buy Now.",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          style: TextButton.styleFrom(
                              backgroundColor: primaryColor),
                        )
                      : SizedBox(),
                ],
              ),
      ),
    );
  }
}
