import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:spike_demo/CNN/scan_product.dart';
import 'package:spike_demo/Constants/models.dart';
import 'package:spike_demo/Constants/styles.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/fryo_icons.dart';
import 'package:spike_demo/Products/ProductPage.dart';
import 'package:spike_demo/Constants/urls.dart';
import 'package:spike_demo/Products/Widgets/HeaderCategoryItem.dart';
import 'package:spike_demo/Products/Widgets/ProductCard.dart';
import 'package:spike_demo/Products/cart_page.dart';
import 'package:spike_demo/Products/mostViewed_products.dart';
import 'package:spike_demo/Products/one_category_products.dart';
import 'package:spike_demo/helpers/apiClient.dart';
import 'package:spike_demo/profile_tab.dart';

class Dashboard extends StatefulWidget {
  final String pageTitle;

  Dashboard({Key key, this.pageTitle}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  bool isLoadingCategories;
  bool isLoadingMostViewed;
  List<Category> allCategories;
  List<ProductBasic> mostViewedProducts;
  int mostViewedPageNum = 1;

  _getCategories() async {
    try {
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.GET_CATEGORIES,
          httpMethod: HTTPMethod.GET,
          authHeader: false,
          context: context);
      response.data.forEach((element) {
        allCategories.add(Category.fromJson(element));
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  _getProducts() async {
    try {
      ApiResponse response = await ApiAdapter.getInstance().callAPI(
          reqUrl: Urls.GET_PRODUCTS + "?page=$mostViewedPageNum",
          httpMethod: HTTPMethod.GET,
          authHeader: false,
          context: context);
      response.data["results"].forEach((element) {
        mostViewedProducts.add(ProductBasic.fromJson(element));
      });
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        isLoadingMostViewed = false;
      });
    }
  }

  @override
  void initState() {
    isLoadingMostViewed = true;
    isLoadingCategories = true;
    allCategories = [];
    mostViewedProducts = [];
    _getCategories();
    _getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    Widget mostViewed(String dealTitle,
        {onViewMore, List<ProductBasic> items}) {
      return Container(
        margin: EdgeInsets.only(top: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            sectionHeader(dealTitle, onViewMore: onViewMore),
            SizedBox(
              height: screenSize.height * 0.26,
              child: (isLoadingMostViewed)
                  ? Center(
                      child: SpinKitThreeBounce(
                        size: 20.0,
                        color: primaryColor,
                      ),
                    )
                  : (mostViewedProducts.length == 0)
                      ? Text('No items available at this moment.',
                          style: taglineText)
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: ProductCard(
                                  food: items[index],
                                  isProductPage: false,
                                  onLike: () {},
                                  onTapped: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            child: ProductPage(
                                              pageTitle:
                                                  mostViewedProducts[index]
                                                      .name,
                                              id: mostViewedProducts[index].id,
                                            ),
                                            type: PageTransitionType
                                                .rightToLeft));
                                  }),
                            );
                          },
                        ),
            )
          ],
        ),
      );
    }

    Widget headerTopCategories() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          sectionHeader('All Categories', onViewMore: () {}),
          SizedBox(
              height: screenSize.height * 0.13,
              child: (isLoadingCategories)
                  ? Center(
                      child: SpinKitThreeBounce(
                        size: 20.0,
                        color: primaryColor,
                      ),
                    )
                  : (allCategories.length == 0)
                      ? Text(
                          "No Data Found",
                          style: taglineText,
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: allCategories.length,
                          itemBuilder: (context, i) {
                            return HeaderCategoryItem(allCategories[i].name,
                                allCategories[i].category_logo, () {
                              Navigator.of(context).push(PageTransition(
                                  child: OneCategoryProduct(
                                    catId: allCategories[i].id,
                                    title: allCategories[i].name,
                                  ),
                                  type: PageTransitionType.rightToLeft));
                            });
                          },
                        ))
        ],
      );
    }

    Widget storeTab(BuildContext context) {
      return ListView(physics: BouncingScrollPhysics(), children: <Widget>[
        headerTopCategories(),
        mostViewed('Best Sellers', onViewMore: () {
          Navigator.push(
              context,
              PageTransition(
                  child: MostBoughtProducts(),
                  type: PageTransitionType.rightToLeft));
        }, items: mostViewedProducts),
      ]);
    }

    final _tabs = [
      storeTab(context),
      CartPage(),
      Text('Tab3'),
      ProfileTab(),
      Text('Tab5'),
    ];

    _showExitDialog(){
      return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Are you sure you want to Exit?"),
            actions: [
              TextButton(
                child: Text("Yes"),
                onPressed: (){
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
              ),
              TextButton(
                child: Text("No"),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
      );
    }

    return WillPopScope(
      // ignore: missing_return
      onWillPop: (){
        _showExitDialog();
      },
      child: Scaffold(
          backgroundColor: bgColor,
          floatingActionButton: FloatingActionButton(
            backgroundColor: primaryColor,
            tooltip: "Scan product",
            onPressed: () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: ScanProduct(),
                      type: PageTransitionType.rightToLeft));
            },
            child: Text("Scan"),
          ),
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              onPressed: () {},
              iconSize: 21,
              icon: Icon(Fryo.funnel),
            ),
            backgroundColor: primaryColor,
            title:
                Text('Frugo', style: logoWhiteStyle, textAlign: TextAlign.center),
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
          body: _tabs[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Fryo.shop),
                  title: Text(
                    'Store',
                    style: tabLinkStyle,
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Fryo.cart),
                  title: Text(
                    'My Cart',
                    style: tabLinkStyle,
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Fryo.heart_1),
                  title: Text(
                    'Favourites',
                    style: tabLinkStyle,
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Fryo.user_1),
                  title: Text(
                    'Profile',
                    style: tabLinkStyle,
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Fryo.cog_1),
                  title: Text(
                    'Settings',
                    style: tabLinkStyle,
                  ))
            ],
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            fixedColor: Colors.green[600],
            onTap: _onItemTapped,
          )),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

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
