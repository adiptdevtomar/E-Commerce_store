import 'package:flutter/material.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/styles.dart';

class HeaderCategoryItem extends StatelessWidget {
  final String name;
  final Function onPressed;
  final String icon;

  HeaderCategoryItem(this.name, this.icon, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 10),
              width: 60,
              height: 60,
              child: FloatingActionButton(
                shape: CircleBorder(),
                heroTag: name,
                onPressed: onPressed,
                backgroundColor: white,
                child: Image.network(
                  icon,
                  height: 40.0,
                ),
              )),
          Text(name + ' ›', style: categoryText)
        ],
      ),
    );
  }
}
