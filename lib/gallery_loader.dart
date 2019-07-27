import 'dart:async';

import 'package:flutter/services.dart';

class GalleryLoader {
  static const MethodChannel _channel =
      const MethodChannel('gallery_loader');

  static Future<String> getGalleryImages({int total: 5}) async {
    final String image = await _channel.invokeMethod('getGalleryImages');
    return image;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
