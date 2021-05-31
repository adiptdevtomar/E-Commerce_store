import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spike_demo/Products/Widgets/product_dialog.dart';

class Alerts {
  Future<bool> showAlertDialog(String msg) {
    return Fluttertoast.showToast(msg: msg, gravity: ToastGravity.BOTTOM);
  }

  Future<bool> showProductDialog(String name, BuildContext context){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        backgroundColor: Colors.transparent,
        content: ProductDialogDetails(maxLabel: name,),
      );
    });
  }
}
