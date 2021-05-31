import 'dart:io';

import 'package:camera/camera.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spike_demo/Alerts/all_alerts.dart';
import 'package:spike_demo/Constants/colors.dart';
import 'package:spike_demo/Constants/globals.dart' as globals;
import 'package:spike_demo/Constants/styles.dart';
import 'package:tflite/tflite.dart';

class ScanProduct extends StatefulWidget {
  @override
  _ScanProductState createState() => _ScanProductState();
}

class _ScanProductState extends State<ScanProduct> with WidgetsBindingObserver {
  CameraController cameraController;
  bool isScanning;

  @override
  void initState() {
    isScanning = false;
    WidgetsBinding.instance?.addObserver(this);
    cameraController = CameraController(
      globals.cameras[0],
      ResolutionPreset.medium,
      enableAudio: true,
    );
    print(cameraController);

    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        print('Camera error ${cameraController.value.errorDescription}');
      }
    });

    cameraController.initialize();

    //loading model
    loadModel().then((value) {
      print("loaded!!");
    });

    super.initState();
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/object_detection.tflite", labels: "assets/labels.txt");
  }

  classifyImage(path) async {
    try {
      List<dynamic> recognitions = await Tflite.runModelOnImage(path: path);
      print(recognitions);
      double maxConfidence = 0.0;
      String maxLabel;
      recognitions.forEach((element) {
        if (element["confidence"] > maxConfidence) {
          maxConfidence = element["confidence"];
          maxLabel = element["label"];
        }
      });
      if (maxConfidence > 0.80) {
        Alerts().showProductDialog(maxLabel, context);
      } else {
        Alerts().showAlertDialog("No product found");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  startScanning() async {
    setState(() {
      isScanning = true;
    });
    var next = math.Random().nextDouble() * 1000000;
    while (next < 100000) {
      next *= 10;
    }
    Directory _storageDirectory = await getExternalStorageDirectory();
    String dir =
        _storageDirectory.path + "/scanned" + "/image${next.toInt()}.jpg";
    try {
      await cameraController.takePicture(dir).then((value) {
        print(dir);
        classifyImage(dir);
      });
    } catch (e) {
      print(e.toString());
      print("Picture Error");
    } finally {
      setState(() {
        isScanning = false;
      });
    }
  }

  stopScanning() async {
    setState(() {
      isScanning = false;
    });
  }

  /*stopScanning() async {
    setState(() {
      isScanning = false;
    });
    cameraController.stopImageStream().then((value) {
      print(
          "----------------------------Image Streaming Stopped--------------------------------------");
    });
  }*/

  /*startScanning() async {
    setState(() {
      isScanning = true;
    });
    cameraController.startImageStream((image) async {
      try {
        await classifyImage(image);
      } catch (e) {
        print("----------------error------------------------------");
        print(e.toString());
      }
    }).then((value) {
      print(
          "----------------------------Image Streaming Started--------------------------------------");
    });
  }*/

  /*classifyImage(CameraImage image) async {
    List<Uint8List> bytesList = image.planes.map((plane) {
      return plane.bytes;
    }).toList();

    try {
      var recognitions = await Tflite.runModelOnFrame(
          imageHeight: image.height,
          imageWidth: image.width,
          rotation: 0,
          numResults: 2,
          bytesList: bytesList);
      print(recognitions);
    } catch (e) {
      print(e.toString());
      print("------------------classify error-------------------------");
    }
  }*/

  @override
  void dispose() {
    Tflite.close();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ),
        body: Stack(
          children: [
            (cameraController == null || !cameraController.value.isInitialized)
                ? SpinKitThreeBounce(
                    color: primaryColor,
                    size: 14.0,
                  )
                : AspectRatio(
                    child: CameraPreview(cameraController),
                    aspectRatio: cameraController.value.aspectRatio,
                  ),
            Positioned(
              bottom: 40.0,
              left: 110.0,
              child: TextButton(
                onPressed: (isScanning)
                    ? () {
                        stopScanning();
                      }
                    : () {
                        startScanning();
                      },
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                  child: Text(
                    (isScanning) ? "Stop Scanning" : "Start Scanning",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                style: TextButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
              ),
            )
          ],
        ));
  }
}
