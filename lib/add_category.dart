import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spike_demo/Alerts/all_alerts.dart';
import 'package:path/path.dart';

import 'Constants/urls.dart';
import 'helpers/apiClient.dart';
import 'package:image_picker/image_picker.dart';

class AddCategory extends StatefulWidget {
  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _name;
  TextEditingController _description;
  File _image;
  final picker = ImagePicker();

  bool isLoading;

  _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _addCategory() async {
    setState(() {
      isLoading = !isLoading;
    });
    try {
      Map<String, dynamic> _map = {
        "name": _name.text,
        "description": _description.text,
        "category_logo": MultipartFile.fromFileSync(_image.path,
            filename: basename(_image.path)),
      };
      print("Request : $_map");
      FormData formData = FormData.fromMap(_map);
      String url = Urls.BASE_URL + Urls.ADD_CATEGORY;
      Map<String, dynamic> mheaders = {
        "Accept": "application/json",
        "content-type": "multipart/form-data",
      };
      print("\n\n\n\n");
      print("Header: $mheaders");
      Options options = new Options(headers: mheaders,receiveTimeout: 20, sendTimeout: 20);
      Dio dio = new Dio();
      var response = await dio.post(url, data: formData);
      print("Response Upload: ${response.data}");
      if (response.statusCode == 201) {
        Alerts().showAlertDialog("Added Successfully!");
      } else {
        Alerts().showAlertDialog("Some Error Occured!");
      }
    } catch (e) {
      print(e.toString());
      Alerts().showAlertDialog("Some Error Occured!");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _name = TextEditingController();
    _description = TextEditingController();
    isLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          height: 400.0,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextFormField(
                    controller: _name,
                    validator: (value) {
                      if (value.isEmpty)
                        return "Cannot be left Empty!";
                      else
                        return null;
                    },
                    decoration: InputDecoration(
                      hintText: "name",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    )),
                TextFormField(
                    controller: _description,
                    validator: (value) {
                      if (value.isEmpty)
                        return "Cannot be left Empty!";
                      else
                        return null;
                    },
                    decoration: InputDecoration(
                      hintText: "description",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    )),
                TextButton(
                    onPressed: () {
                      _pickImage();
                    },
                    child: Text("Select Image")),
                (_image == null)
                    ? Text("No image Selected")
                    : Text(basename(_image.path)),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        _image = null;
                      });
                    },
                    child: Text(
                      "Clear Image",
                      style: TextStyle(color: Colors.green),
                    )),
                TextButton(
                    onPressed: () {
                      if (_formKey.currentState.validate() && _image != null) {
                        FocusScope.of(context).unfocus();
                        _addCategory();
                      }
                    },
                    child: isLoading
                        ? CupertinoActivityIndicator()
                        : Text("Submit")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
