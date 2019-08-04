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
  int _totalImages = 0;
  bool _permissioned = false;

  @override
  void initState() {
    super.initState();
    initPermissions();
  }

  Future<void> initPermissions() async {
    PermissionGroup group =
        Platform.isIOS ? PermissionGroup.photos : PermissionGroup.storage;
    PermissionStatus prova =
        await PermissionHandler().checkPermissionStatus(group);
    bool permitted = (await PermissionHandler().checkPermissionStatus(group)) ==
        PermissionStatus.granted;
    if (!permitted) {
      var permissionStatus =
          (await PermissionHandler().requestPermissions([group]))[group];
      print(permissionStatus);
      if (permissionStatus == PermissionStatus.granted) {
        permitted = true;
      }
    }
    setState(() {
      _permissioned = permitted;
    });
    _totalImages = await GalleryLoader.getNumberOfImages();
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
                          future: GalleryLoader.getGalleryImages(
                              total: 1,
                              startingIndex: index,
                          ),
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
