import 'package:flutter/material.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/models.dart';
import 'package:spike_demo/Constants/styles.dart';

class ProductCard extends StatelessWidget {
  final ProductBasic food;
  final Function onTapped;
  final Function onLike;
  final bool isProductPage;

  ProductCard({this.food, this.isProductPage, this.onLike, this.onTapped});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Container(
        width: screenSize.width * 0.35,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: screenSize.height * 0.15,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: white,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: onTapped,
                      child: Image.network(
                        food.image,
                        fit: BoxFit.contain,
                      )),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onLike,
                    child: Icon(
                      Icons.favorite,
                      color: primaryColor,
                    ) /*Icon(
                      (food.userLiked) ? Icons.favorite : Icons.favorite_border,
                      color: (food.userLiked) ? primaryColor : darkText,
                      size: 20,
                    )*/
                    ,
                  ),
                ),
                Positioned(
                    top: 10,
                    left: 10,
                    child:
                        SizedBox() /*(food.discount != null)
                        ? Container(
                            padding: EdgeInsets.only(
                                top: 5, left: 10, right: 10, bottom: 5),
                            decoration: BoxDecoration(
                                color: Colors.grey[600],
                                borderRadius: BorderRadius.circular(50)),
                            child: Text('-' + food.discount.toString() + '%',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          )
                        : SizedBox(width: 0)*/
                    )
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              food.name,
              style: foodNameText,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Text(food.price.toString(), style: priceText),
          ],
        ));
  }
}
