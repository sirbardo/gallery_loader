package com.example.gallery_loader;

import java.lang.Math;
import java.io.ByteArrayOutputStream;
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
import android.media.ThumbnailUtils;

/** GalleryLoaderPlugin */
public class GalleryLoaderPlugin implements MethodCallHandler {
  /** Plugin registration. */

  private Activity activity;

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "gallery_loader");
    channel.setMethodCallHandler(new GalleryLoaderPlugin(registrar.activity()));
  }

  GalleryLoaderPlugin(Activity activity) {
    this.activity = activity;
  }

  private void getThumbnails(MethodCall call, Result result) {
    Stopwatch timer = new Stopwatch();
    timer.start();
    Integer nToRead = call.argument("nToRead");
    Integer startingIndex = call.argument("startingIndex");
    if (startingIndex == null)
      startingIndex = 0;
    if (nToRead == null)
      nToRead = 1;

    String[] projection = { MediaStore.Images.Thumbnails.DATA };
    Uri uri = MediaStore.Images.Thumbnails.EXTERNAL_CONTENT_URI;
    Cursor cursor = MediaStore.Images.Thumbnails.queryMiniThumbnails(activity.getContentResolver(), uri,
        MediaStore.Images.Thumbnails.MINI_KIND, projection);
    int i = 0;

    if (!cursor.moveToLast())
      Log.d("getThumbnails", "Found no thumbnails.");
    ArrayList<String> images = new ArrayList<String>();

    do {
      String absolutePathOfImage = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA));
      images.add(absolutePathOfImage);
      i += 1;
    } while (i < nToRead && cursor.moveToPrevious());

    timer.stop();
    Log.d("getThumbnails", "Took: " + Long.toString(timer.getElapsedTime()));
    result.success(images);
  }

  private void getGalleryImages(MethodCall call, Result result) {
    Stopwatch timer = new Stopwatch();
    timer.start();
    int nToRead = call.argument("nToRead");
    int startingIndex = call.argument("startingIndex");
    Integer targetWidth = call.argument("targetWidth");
    Integer targetHeight = call.argument("targetHeight");
    if (targetWidth == null)
      targetWidth = 0;
    if (targetHeight == null)
      targetHeight = 0;

    ArrayList<byte[]> images = new ArrayList<byte[]>();

    Uri uri = android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
    String[] projection = { MediaStore.MediaColumns.DATA };
    Cursor cursor = activity.getContentResolver().query(uri, projection, null, null,
        MediaStore.MediaColumns.DATE_ADDED + "  desc");
    cursor.moveToPosition(startingIndex - 1);
    int i = 0;
    while (i < nToRead && cursor.moveToNext()) {
      i++;
      String absolutePathOfImage = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA));
      if (targetWidth == 0 || targetHeight == 0) {
        Bitmap original = BitmapFactory.decodeFile(absolutePathOfImage);
        ByteArrayOutputStream stream = new ByteArrayOutputStream(original);
        original.compress(Bitmap.CompressFormat.JPEG, 70, stream);
        images.add(stream.toByteArray());
      } else {
        Bitmap original = BitmapFactory.decodeFile(absolutePathOfImage);
        float originalWidth = original.getWidth();
        float originalHeight = original.getHeight();

        /*
         * if (targetWidth > targetHeight) { float scale = originalWidth / targetWidth;
         * targetHeight = Math.round(((float) targetHeight) * scale); } else { float
         * scale = originalHeight / targetHeight; targetWidth = Math.round(((float)
         * targetWidth) * scale); }
         */

        Bitmap out = Bitmap.createScaledBitmap(original, targetWidth, targetHeight, false);
        ByteArrayOutputStream stream = new ByteArrayOutputStream(out);
        original.compress(Bitmap.CompressFormat.JPEG, 70, stream);
        images.add(stream.toByteArray());
      }
    }
    timer.stop();
    Log.d("getImages", "Took: " + Long.toString(timer.getElapsedTime()));
    result.success(images);
    /*
     * } else { int i = 0; while (i < nToRead && cursor.moveToNext()) { i++;
     * Log.d("Channel", "loading next image"); String absolutePathOfImage =
     * cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA));
     * images.add(absolutePathOfImage); Log.d("Channel", "Returning: " +
     * absolutePathOfImage); } Log.d("Channel", "About to return");
     * result.success(images); }
     */
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {

    if (call.method.equals("getThumbnails")) {
      getThumbnails(call, result);
    } else if (call.method.equals("getNumberOfImages")) {
      String[] projection = { MediaStore.MediaColumns.DATA };
      Uri uri = android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
      Cursor cursor = activity.getContentResolver().query(uri, projection, null, null, null);
      result.success(cursor.getCount());
    } else if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("getGalleryImages")) {
      getGalleryImages(call, result);
    } else {
      result.notImplemented();
    }
  }
}
