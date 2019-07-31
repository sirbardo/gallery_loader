import 'dart:async';

import 'package:flutter/services.dart';

class GalleryLoader {
  static const MethodChannel _channel = const MethodChannel('gallery_loader');

  static Future<List<String>> getGalleryImages({
    int total: 5,
    int startingIndex: 0,
    int targetWidth: 0,
    int targetHeight: 0,
  }) async {

    final images = await _channel
        .invokeListMethod<String>('getGalleryImages', <String, dynamic>{
      'nToRead': total,
      'startingIndex': startingIndex,
      'targetWidth' : targetWidth,
      'targetHeight' : targetHeight,
    });
    print("Returned $images");
    return images;
  }

  static Future<int> getNumberOfImages() async {
    print("Asking for number of images");
    final int numberOfImages = await _channel.invokeMethod('getNumberOfImages');
    print("OS returned $numberOfImages number of images");
    return numberOfImages;
  }

  static Future<String> restartCursor() async {
    String state = await _channel.invokeMethod('restartCursor');
    return state;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
