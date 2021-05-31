import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/fryo_icons.dart';
import 'package:spike_demo/Constants/models.dart';
import 'package:spike_demo/Constants/styles.dart';
import 'package:spike_demo/Constants/urls.dart';
import 'package:spike_demo/Products/ProductPage.dart';
import 'package:spike_demo/helpers/apiClient.dart';

import 'Widgets/ProductCard.dart';

class MostBoughtProducts extends StatefulWidget {
  @override
  _MostBoughtProductsState createState() => _MostBoughtProductsState();
}

class _MostBoughtProductsState extends State<MostBoughtProducts> {

  int mostBoughtPageNum;
  List<ProductBasic> mostBoughtProducts;
  Map<dynamic, dynamic> responseData;
  bool isLoadingMostBought;
  bool isLoadingMoreProducts;

  _getProducts() async {
    try {
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.GET_PRODUCTS + "?page=$mostBoughtPageNum",
          httpMethod: HTTPMethod.GET,
          authHeader: false,
          context: context);
      responseData = response.data;
      response.data["results"].forEach((element) {
        mostBoughtProducts.add(ProductBasic.fromJson(element));
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoadingMostBought = false;
        isLoadingMoreProducts = false;
      });
    }
  }

  @override
  void initState() {
    isLoadingMostBought = true;
    mostBoughtProducts = [];
    mostBoughtPageNum = 1;
    isLoadingMoreProducts = false;
    _getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          iconSize: 21,
          icon: Icon(Fryo.funnel),
        ),
        backgroundColor: primaryColor,
        title: Text('Fryo', style: logoWhiteStyle, textAlign: TextAlign.center),
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
      body: (isLoadingMostBought)
          ? Center(
              child: SpinKitThreeBounce(
                color: Colors.green,
                size: 20.0,
              ),
            )
          : (mostBoughtProducts.length == 0)
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
                        child: Text("Most Bought Products",
                            style: categoryText.copyWith(fontSize: 25.0)),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: mostBoughtProducts.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 15.0),
                        itemBuilder: (context, index) {
                          return ProductCard(
                              food: mostBoughtProducts[index],
                              isProductPage: false,
                              onLike: () {},
                              onTapped: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        child: ProductPage(
                                          pageTitle:
                                              mostBoughtProducts[index].name,
                                          id: mostBoughtProducts[index].id,
                                        ),
                                        type: PageTransitionType.rightToLeft));
                              });
                        },
                      ),
                      (responseData["next"] != null)
                          ? TextButton(
                              onPressed: (isLoadingMoreProducts)
                                  ? () {}
                                  : () {
                                      setState(() {
                                        mostBoughtPageNum += 1;
                                        isLoadingMoreProducts = true;
                                      });
                                      _getProducts();
                                    },
                              child: (isLoadingMoreProducts)
                                  ? SpinKitThreeBounce(
                                      color: primaryColor,
                                      size: 12.0,
                                    )
                                  : Text("Load More"))
                          : SizedBox()
                    ],
                  ),
                ),
    );
  }
}
