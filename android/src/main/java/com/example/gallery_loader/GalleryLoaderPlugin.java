package com.example.gallery_loader;

import java.util.ArrayList;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import android.app.Activity;
import android.provider.MediaStore;
import android.util.Log;
import android.net.Uri;
import android.database.Cursor;

/** GalleryLoaderPlugin */
public class GalleryLoaderPlugin implements MethodCallHandler {
  /** Plugin registration. */

  private Activity activity;
  public Cursor cursor;

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "gallery_loader");
    channel.setMethodCallHandler(new GalleryLoaderPlugin(registrar.activity()));
  }

  GalleryLoaderPlugin(Activity activity) {
    this.activity = activity;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("getGalleryImages")) {
      int nToRead = call.argument("nToRead");
       ArrayList<String> images = new ArrayList<String>();
      if (cursor == null) {

        String[] projection = { MediaStore.MediaColumns.DATA, MediaStore.MediaColumns.DATE_ADDED };

        Uri uri = android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
        Cursor cursor = activity.getContentResolver().query(uri, projection, null, null,
            MediaStore.MediaColumns.DATE_ADDED + "  desc");
        Log.d("Channel", uri.toString());
        Log.d("Channel", cursor.toString());
        Log.d("Channel", activity.toString());
        Log.d("Channel", projection.toString());
        int i = 0;
        while (i < nToRead && cursor.moveToNext()) {
          i++;
          String absolutePathOfImage = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA));
          images.add(absolutePathOfImage);
        }
      }
      else {
        int i = 0;
        while (i < nToRead && cursor.moveToNext()) {
          i++;
          String absolutePathOfImage = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA));
          images.add(absolutePathOfImage);
        }
      }
      result.success(images);
    } else {
      result.notImplemented();
    }
  }
}
