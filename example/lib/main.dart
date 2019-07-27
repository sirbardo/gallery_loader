import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:gallery_loader/gallery_loader.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List<String> _images;
  bool _permissioned = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initPermissions();
  }

  Future<void> initPermissions() async {
    bool permitted =
        await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
    if (!permitted) {
      var permissionStatus = await SimplePermissions.requestPermission(
          Permission.ReadExternalStorage);
      print(permissionStatus);
      if (permissionStatus == PermissionStatus.authorized) {
        permitted = true;
        initGalleryMethod();
      }
    } else {
      initGalleryMethod();
    }

    setState(() {
      _permissioned = permitted;
    });
  }

  Future<void> initGalleryMethod() async {
    final images = <String>[];
    try {
      print("Trying...");
      images
        ..addAll(await GalleryLoader.getGalleryImages(total: 1))
        ..addAll(await GalleryLoader.getGalleryImages(total: 1))
        ..addAll(await GalleryLoader.getGalleryImages(total: 1))
        ..addAll(await GalleryLoader.getGalleryImages(total: 1))
        ..addAll(await GalleryLoader.getGalleryImages(total: 1))
        ..addAll(await GalleryLoader.getGalleryImages(total: 1));
      print("Done.");
    } on PlatformException catch (e) {
      print(e);
    }

    print("About to set state.");
    print(images);
    setState(() {
      _images = images;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GalleryLoader.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
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
          child: ListView.builder(
            itemBuilder: (context, index) => FutureBuilder<String>(
                future: GalleryLoader.getGalleryImages(total: 1)
                    .then((el) => el.first),
                builder: (con, snap) => Image.file(File(snap.data))),
          ),
        ),
      ),
    );
  }
}
