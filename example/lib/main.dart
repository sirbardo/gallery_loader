import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:gallery_loader/gallery_loader.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List<String> _images;
  int _totalImages = 0;
  bool _permissioned = false;

  @override
  void initState() {
    super.initState();
    initPermissions();
  }

  Future<void> initPermissions() async {
    print("Boutta start initpermissions");
    PermissionGroup group =
        Platform.isIOS ? PermissionGroup.photos : PermissionGroup.storage;
    PermissionStatus prova =
        await PermissionHandler().checkPermissionStatus(group);
    print("Ok, we managed to get status: it's $prova");
    bool permitted = (await PermissionHandler().checkPermissionStatus(group)) ==
        PermissionStatus.granted;
    print("Done with permissions yo");
    if (!permitted) {
      print("Boutta ask for permission yo");
      var permissionStatus =
          (await PermissionHandler().requestPermissions([group]))[group];
      print(permissionStatus);
      if (permissionStatus == PermissionStatus.granted) {
        permitted = true;
      }
    }
    print("Boutta set permission state to $permitted");
    setState(() {
      _permissioned = permitted;
    });
    getImageCount();
  }

  Future<List<String>> getImages(
      {total: 1, startingIndex: 0, width: 0, height: 0}) async {
    final images = await GalleryLoader.getGalleryImages(
        total: total,
        startingIndex: startingIndex,
        targetWidth: width,
        targetHeight: height);
    return images;
  }

  Future<void> getImageCount() async {
    int totalImages = await GalleryLoader.getNumberOfImages();
    setState(() {
      _totalImages = totalImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: (_permissioned && _totalImages != 0)
                ? ListView.builder(
                    itemCount: _totalImages,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                          future: getImages(
                              total: 1,
                              startingIndex: index,
                              width: 200,
                              height: 200),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                              case ConnectionState.active:
                                return Align(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                );
                              case ConnectionState.done:
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  print(snapshot.data);
                                  if (snapshot.data.length == 0)
                                    return Container();
                                  var pageData =
                                      snapshot.data as List<String>;
                                  if (pageData.first == "" ||
                                      pageData.length == 0)
                                    return Align(
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator());
                                  return Column(children: <Widget>[
                                    Image.file(File(pageData.first)),
                                  ]);
                                }
                            }
                          });
                    },
                  )
                : CircularProgressIndicator()),
      ),
    );
  }
}
