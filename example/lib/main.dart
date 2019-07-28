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
  int _totalImages = 0;
  bool _permissioned = false;

  @override
  void initState() {
    super.initState();
    initPermissions();
  }

  Future<void> initPermissions() async {
    print("Boutta start initpermissions");
    PermissionStatus prova = await SimplePermissions.getPermissionStatus(
        Permission.ReadExternalStorage);
    print("Ok, we managed to get status: it's $prova");
    bool permitted =
        await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
    print("Done with permissions yo");
    if (!permitted) {
      print("Boutta ask for permission yo");
      var permissionStatus = await SimplePermissions.requestPermission(
          Permission.ReadExternalStorage);
      print(permissionStatus);
      if (permissionStatus == PermissionStatus.authorized) {
        permitted = true;
      }
    }
    print("Boutta set permission state to $permitted");
    setState(() {
      _permissioned = permitted;
    });
    getImageCount();
  }

  Future<List<String>> getImages({total: 1}) async {
      final images = await GalleryLoader.getGalleryImages(total: total);
      return images;
   }
  
  Future<void> getImageCount() async{
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
          child: 
             (_permissioned && _totalImages != 0) ? ListView.builder(
              itemCount: _totalImages,
              itemBuilder: (context, index){
                   return FutureBuilder(
                  future: getImages(total: 1),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                      return Align(alignment: Alignment.center, child: CircularProgressIndicator(),);
                      case ConnectionState.done:
                        if(snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          print(snapshot.data);
                          if (snapshot.data.length == 0)
                            return Container();
                          var pageData = snapshot.data as List<String>;
                          if (pageData.first == "" || pageData.length == 0)
                            return Align(alignment: Alignment.center, child: CircularProgressIndicator());
                          return Image.file(File(pageData.first));
                        }
                    }
                  });
              },
            )
            :
            CircularProgressIndicator()
        ),
      ),
    );
  }
}
