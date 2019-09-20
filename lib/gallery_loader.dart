import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class GalleryLoader {
  static const MethodChannel _channel = const MethodChannel('gallery_loader');

  static Future<List<Uint8List>> getGalleryImages({
    int total: 5,
    int startingIndex: 0,
    int targetWidth: 0,
    int targetHeight: 0,
    bool newCursor: false,
  }) async {
    final images = await _channel
        .invokeListMethod<Uint8List>('getGalleryImages', <String, dynamic>{
      'nToRead': total,
      'startingIndex': startingIndex,
      'targetWidth' : targetWidth,
      'targetHeight' : targetHeight,
      'newCursor' : newCursor,
    });
    return images;
  }

  static Future<List<Uint8List>> getThumbnails({
    int total: 5,
    int startingIndex: 0,
    bool newCursor = false,
  }) async {

    final images = await _channel
        .invokeListMethod<Uint8List>('getThumbnails', <String, dynamic>{
      'nToRead': total,
      'startingIndex': startingIndex,
      'newCursor': newCursor,
    });
    return images;
  }

  static Future<int> getNumberOfImages() async {
    print("Asking for number of images");
    final int numberOfImages = await _channel.invokeMethod('getNumberOfImages');
    print("OS returned $numberOfImages number of images");
    return numberOfImages;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
