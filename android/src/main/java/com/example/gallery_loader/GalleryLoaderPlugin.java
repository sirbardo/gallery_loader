package com.example.gallery_loader;

import java.lang.Math;
import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.UUID;
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
import android.graphics.BitmapFactory;
import android.graphics.Bitmap;
import android.os.Environment;

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

    if (call.method.equals("restartCursor")) {
      if (cursor == null)
        result.success("Done");
      else {
        cursor.close();
        this.cursor = null;
        result.success("Done");
      }
    } else if (call.method.equals("getNumberOfImages")) {
      String[] projection = { MediaStore.MediaColumns.DATA };
      Uri uri = android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
      cursor = activity.getContentResolver().query(uri, projection, null, null, null);
      result.success(cursor.getCount());
    } else if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("getGalleryImages")) {
      int nToRead = call.argument("nToRead");
      int startingIndex = call.argument("startingIndex");
      Integer targetWidth = call.argument("targetWidth");
      Integer targetHeight = call.argument("targetHeight");
      if (targetWidth == null)
        targetWidth = 0;
      if (targetHeight == null)
        targetHeight = 0;

      ArrayList<String> images = new ArrayList<String>();

      Uri uri = android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
      String[] projection = { MediaStore.MediaColumns.DATA };
      cursor = activity.getContentResolver().query(uri, projection, null, null,
          MediaStore.MediaColumns.DATE_ADDED + "  desc");
      cursor.moveToPosition(startingIndex - 1);
      int i = 0;
      while (i < nToRead && cursor.moveToNext()) {
        i++;
        String absolutePathOfImage = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA));
        if (targetWidth == 0 || targetHeight == 0) {
          images.add(absolutePathOfImage);
        } else {
          Bitmap original = BitmapFactory.decodeFile(absolutePathOfImage);
          float originalWidth = original.getWidth();
          float originalHeight = original.getHeight();

          /*
          if (targetWidth > targetHeight) {
            float scale = originalWidth / targetWidth;
            targetHeight = Math.round(((float) targetHeight) * scale);
          } else {
            float scale = originalHeight / targetHeight;
            targetWidth = Math.round(((float) targetWidth) * scale);
          }
          */

          Bitmap out = Bitmap.createScaledBitmap(original, targetWidth, targetHeight, false);

          File outputDir = activity.getCacheDir();
          String finalPath = "resize" + UUID.randomUUID().toString() +  ".jpg";
          File outputFile;
          FileOutputStream fOut;
          try {
            outputFile = new File(outputDir, finalPath);
            fOut = new FileOutputStream(outputFile);
            out.compress(Bitmap.CompressFormat.JPEG, 100, fOut);
            fOut.flush();
            fOut.close();
            images.add(outputFile.getAbsolutePath());
          } catch (Exception e) {
            Log.d("GalleryImage", "Exception in file compress", e);
          }

        }
      }
      result.success(images);
      /*
       * } else { int i = 0; while (i < nToRead && cursor.moveToNext()) { i++;
       * Log.d("Channel", "loading next image"); String absolutePathOfImage =
       * cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA));
       * images.add(absolutePathOfImage); Log.d("Channel", "Returning: " +
       * absolutePathOfImage); } Log.d("Channel", "About to return");
       * result.success(images); }
       */
    } else {
      result.notImplemented();
    }
  }
}
