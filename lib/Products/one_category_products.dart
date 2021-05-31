import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/fryo_icons.dart';
import 'package:spike_demo/Constants/models.dart';
import 'package:spike_demo/Constants/styles.dart';
import 'package:spike_demo/Constants/urls.dart';
import 'package:spike_demo/Products/Widgets/ProductCard.dart';
import 'package:spike_demo/helpers/apiClient.dart';

import 'ProductPage.dart';

class OneCategoryProduct extends StatefulWidget {
  final String catId;
  final String title;

  OneCategoryProduct({@required this.catId, this.title});

  @override
  _OneCategoryProductState createState() => _OneCategoryProductState();
}

class _OneCategoryProductState extends State<OneCategoryProduct> {
  bool isLoadingProducts;
  List<ProductBasic> productsOfCat;

  _getProductsOfCategory(catId) async {
    try {
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.GET_ALL_PRODUCTS_OF_CATEGORY + widget.catId,
          httpMethod: HTTPMethod.GET,
          context: context);
      response.data.forEach((element) {
        productsOfCat.add(ProductBasic.fromJson(element));
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoadingProducts = false;
      });
    }
  }

  @override
  void initState() {
    isLoadingProducts = true;
    productsOfCat = [];
    _getProductsOfCategory(widget.catId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text("Frugo", style: logoWhiteStyle, textAlign: TextAlign.center),
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.all(0),
            onPressed: () {},
            iconSize: 21,
            icon: Icon(Fryo.magnifier),
          ),
          IconButton(
            padding: EdgeInsets.all(0),
            onPressed: () {},
            iconSize: 21,
            icon: Icon(Fryo.alarm),
          )
        ],
      ),
      body: (isLoadingProducts)
          ? Center(
              child: SpinKitThreeBounce(
                color: Colors.green,
                size: 20.0,
              ),
            )
          : (productsOfCat.length == 0)
              ? Center(
                  child: Text(
                    "No products Found.",
                    style: taglineText,
                  ),
                )
              : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  child: ListView(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Text(widget.title,
                            style: categoryText.copyWith(fontSize: 25.0)),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: productsOfCat.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 15.0),
                        itemBuilder: (context, index) {
                          return ProductCard(
                              food: productsOfCat[index],
                              isProductPage: false,
                              onLike: () {},
                              onTapped: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        child: ProductPage(
                                          pageTitle: productsOfCat[index].name,
                                          id: productsOfCat[index].id,
                                        ),
                                        type: PageTransitionType.rightToLeft));
                              });
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
