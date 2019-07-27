import 'dart:async';

import 'package:flutter/services.dart';

class GalleryLoader {
  static const MethodChannel _channel = const MethodChannel('gallery_loader');

  static Future<List<String>> getGalleryImages({int total: 5}) async {
    final images =
        List<String>.from(await _channel.invokeMethod('getGalleryImages', <String, dynamic>{
          'nToRead' : total
        }));

    return images;
  }

  static Future<int> getNumberOfImages() async {
    final int numberOfImages = await _channel.invokeMethod('getNumberOfImages');
    return numberOfImages;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
