import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:spike_demo/Constants/models.dart';
import 'package:spike_demo/Constants/styles.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/buttons.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:spike_demo/Constants/urls.dart';
import 'package:spike_demo/Products/Widgets/ProductCard.dart';
import 'package:spike_demo/helpers/apiClient.dart';
import 'package:spike_demo/Alerts/all_alerts.dart';
import 'package:spike_demo/Constants/globals.dart' as globals;

class ProductPage extends StatefulWidget {
  final String pageTitle;
  final String id;

  ProductPage({Key key, this.pageTitle, this.id}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Product product;
  Size screenSize;
  double _rating = 4;
  int _quantity = 1;
  bool isLoadingDetails;
  bool isAddingToCart;
  bool isLoadingRecommendations = true;
  List<ProductBasic> recommendedProducts = [];
  String stockText;
  TextStyle stockStyle;

  Widget sectionHeader(String headerTitle, {onViewMore}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 15, top: 10),
          child: Text(headerTitle, style: h4),
        ),
        Container(
          margin: EdgeInsets.only(left: 15, top: 2),
          child: FlatButton(
            onPressed: onViewMore,
            child: Text('View all ›', style: contrastText),
          ),
        )
      ],
    );
  }

  _addToCart(quantity) async {
    var reqBody = {
      "cart": globals.cartId,
      "product": widget.id,
      "quantity": _quantity
    };
    try {
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.ADD_ITEM_TO_CART,
          requestBody: reqBody,
          httpMethod: HTTPMethod.POST,
          context: context);
      if (response.data["message"] != null) {
        Alerts().showAlertDialog(response.data["message"]);
      } else {
        Alerts().showAlertDialog("An Error Occurred!");
      }
    } catch (e) {
      print(e.toString());
      Alerts().showAlertDialog("An Error Occurred!");
    } finally {
      setState(() {
        isAddingToCart = false;
      });
    }
  }

  _getStockText(int quantity) {
    if (quantity > 10) {
      setState(() {
        stockText = "In Stock.";
        stockStyle = taglineText.copyWith(color: Colors.green);
      });
    } else if (quantity > 5) {
      setState(() {
        stockText = "Product Selling fast!";
        stockStyle = taglineText.copyWith(color: Colors.red);
      });
    } else if (quantity >= 1) {
      setState(() {
        stockText = "Only $quantity in Stock!";
        stockStyle = taglineText.copyWith(color: Colors.red);
      });
    } else {
      setState(() {
        stockText = "Out of Stock!";
        stockStyle = taglineText.copyWith(color: Colors.red);
      });
    }
  }

  _getProductRecommendation() async {
    var reqBody = {"product_id": widget.id};
    try {
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.GET_RECOMMENDATION,
          httpMethod: HTTPMethod.POST,
          requestBody: reqBody,
          context: context);
      response.data.forEach((element) {
        recommendedProducts.add(ProductBasic.fromJson(element));
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoadingRecommendations = false;
      });
    }
  }

  _getProductDetails() async {
    try {
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.GET_PRODUCT_DETAILS + widget.id,
          httpMethod: HTTPMethod.GET,
          context: context);
      product = Product.fromJson(response.data);
      _getStockText(product.quantity);
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoadingDetails = false;
      });
    }
  }

  @override
  void initState() {
    isLoadingDetails = true;
    isAddingToCart = false;
    stockText = "";
    _getProductRecommendation();
    _getProductDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    Widget productHeader() {
      return Stack(
        fit: StackFit.expand,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: Image.network(product.image),
            style: ElevatedButton.styleFrom(primary: Colors.white),
          )
        ],
      );
    }

    return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: bgColor,
          centerTitle: true,
          leading: BackButton(
            color: darkText,
          ),
          title: Text(widget.pageTitle, style: h4),
        ),
        body: (isLoadingDetails)
            ? Center(child: CupertinoActivityIndicator())
            : (product == null)
                ? Text("Please retry!")
                : ListView(
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  margin:
                                      EdgeInsets.only(top: 100, bottom: 20.0),
                                  padding:
                                      EdgeInsets.only(top: 100, bottom: 50),
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(product.name, style: h5),
                                      Text("₹ " + product.price, style: h3),
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: 5, bottom: 20),
                                        child: SmoothStarRating(
                                          allowHalfRating: false,
                                          onRated: (v) {
                                            setState(() {
                                              _rating = v;
                                            });
                                          },
                                          starCount: 5,
                                          rating: _rating,
                                          size: 27.0,
                                          color: Colors.orange,
                                          borderColor: Colors.orange,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 10, bottom: 25),
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              child:
                                                  Text('Quantity', style: h6),
                                              margin:
                                                  EdgeInsets.only(bottom: 15),
                                            ),
                                            Text(
                                              stockText,
                                              style: stockStyle,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                OutlinedButton(
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    shape: CircleBorder(),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      if (_quantity == 1)
                                                        return;
                                                      _quantity -= 1;
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(_quantity.toString(),
                                                    style: h3),
                                                OutlinedButton(
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    shape: CircleBorder(),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      if (_quantity <
                                                          product.quantity)
                                                        _quantity += 1;
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Description',
                                        style: h6,
                                      ),
                                      SizedBox(
                                        height: 7.0,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Text(
                                          product.description,
                                          style: categoryText,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Container(
                                        width: 180,
                                        child:
                                            froyoOutlineBtn('Buy Now', () {}),
                                      ),
                                      (isAddingToCart)
                                          ? Container(
                                              width: 180,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor: primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                ),
                                                child: SpinKitThreeBounce(
                                                  color: Colors.white,
                                                  size: 10.0,
                                                ),
                                                onPressed: () {},
                                              ))
                                          : Container(
                                              width: 180,
                                              child: froyoFlatBtn('Add to Cart',
                                                  () {
                                                setState(() {
                                                  isAddingToCart = true;
                                                });
                                                _addToCart(_quantity);
                                              }),
                                            )
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 15,
                                            spreadRadius: 5,
                                            color: Color.fromRGBO(0, 0, 0, .05))
                                      ]),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: screenSize.width * 0.4,
                                  height: screenSize.height * 0.2,
                                  child: productHeader(),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      (isLoadingRecommendations)
                          ? SizedBox()
                          : (recommendedProducts.length == 0)
                              ? SizedBox()
                              : sectionHeader("People also buy",
                                  onViewMore: () {}),
                      (isLoadingRecommendations)
                          ? Center(
                              child: SpinKitThreeBounce(
                                size: 20.0,
                                color: primaryColor,
                              ),
                            )
                          : (recommendedProducts.length == 0)
                              ? SizedBox()
                              : SizedBox(
                                  height: screenSize.height * 0.26,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: recommendedProducts.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(left: 15.0),
                                        child: ProductCard(
                                            food: recommendedProducts[index],
                                            isProductPage: false,
                                            onLike: () {},
                                            onTapped: () {
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      child: ProductPage(
                                                        pageTitle:
                                                            recommendedProducts[
                                                                    index]
                                                                .name,
                                                        id: recommendedProducts[
                                                                index]
                                                            .id,
                                                      ),
                                                      type: PageTransitionType
                                                          .rightToLeft));
                                            }),
                                      );
                                    },
                                  ),
                                ),
                    ],
                  ));
  }
}
