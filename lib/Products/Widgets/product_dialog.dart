import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/models.dart';
import 'package:spike_demo/Constants/styles.dart';
import 'package:spike_demo/Constants/urls.dart';
import 'package:spike_demo/Products/ProductPage.dart';
import 'package:spike_demo/helpers/apiClient.dart';

class ProductDialogDetails extends StatefulWidget {
  final String maxLabel;

  ProductDialogDetails({@required this.maxLabel});

  @override
  _ProductDialogDetailsState createState() => _ProductDialogDetailsState();
}

class _ProductDialogDetailsState extends State<ProductDialogDetails> {
  String productId;
  Product product;
  bool isLoading;

  _getProductDetails(String productId) async {
    try {
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.GET_PRODUCT_DETAILS + productId,
          httpMethod: HTTPMethod.GET,
          context: context);
      product = Product.fromJson(response.data);
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _getProductId() {
    productId = "";
    switch (widget.maxLabel) {
      case "speaker":
        productId = "VlnGDoEr";
        break;

      case "watch":
        productId = "FPXifyz7";
        break;

      case "headphones":
        productId = "";
        break;
    }
    _getProductDetails(productId);
  }

  @override
  void initState() {
    isLoading = true;
    _getProductId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
        child: (isLoading)
            ? Container(
                height: 30.0,
                child: SpinKitThreeBounce(
                  color: primaryColor,
                  size: 15.0,
                ),
              )
            : (product == null)
                ? Text("Cannot load details!")
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.15,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: white,
                                  elevation: 12,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                                onPressed: () {},
                                child: Image.network(
                                  product.image,
                                  fit: BoxFit.contain,
                                )),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {},
                              child: Icon(
                                Icons.favorite,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          Positioned(top: 10, left: 10, child: SizedBox())
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        product.name,
                        style: foodNameText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Text("₹ " + product.price, style: priceText),
                      TextButton(
                        child: Text(
                          "Review Product -> ",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: ProductPage(
                                    id: productId,
                                    pageTitle: product.name,
                                  ),
                                  type: PageTransitionType.rightToLeft));
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                      ),
                    ],
                  ));
  }
}
