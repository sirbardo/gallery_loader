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
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;

/** GalleryLoaderPlugin */
public class GalleryLoaderPlugin implements MethodCallHandler {
  /** Plugin registration. */

  private Activity activity;
  private Cursor cursor;

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "gallery_loader");
    channel.setMethodCallHandler(new GalleryLoaderPlugin(registrar.activity()));
  }

  GalleryLoaderPlugin(Activity activity) {
    this.activity = activity;
  }

  private void getThumbnails(final MethodCall call, final Result result) {

    new Thread(new Runnable() {
      @Override
      public void run() {

        Stopwatch timer = new Stopwatch();
        timer.start();

        final int nToRead = call.argument("nToRead");
        final int startingIndex = call.argument("startingIndex");
        final Boolean newCursor = call.argument("newCursor");

        final ArrayList<byte[]> images = new ArrayList<byte[]>();

        if (cursor == null || newCursor) {
          Log.d("getImages", "New cursor");
          Uri uri = android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
          String[] projection = { MediaStore.MediaColumns.DATA, MediaStore.Images.Media._ID};
          cursor = activity.getContentResolver().query(uri, projection, null, null,
              MediaStore.MediaColumns.DATE_ADDED + "  desc");
        }

        cursor.moveToPosition(startingIndex - 1);

        int i = 0;
        while (i < nToRead && cursor.moveToNext()) {
          i++;
          String id = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID));
          Bitmap bmp = MediaStore.Images.Thumbnails.getThumbnail(activity.getContentResolver(), Long.parseLong(id),
          MediaStore.Images.Thumbnails.MINI_KIND, null);

          if (bmp == null){
            continue;
          }


          ByteArrayOutputStream stream = new ByteArrayOutputStream();
          bmp.compress(Bitmap.CompressFormat.JPEG, 90, stream);

          images.add(stream.toByteArray());

        }
        timer.stop();
        Log.d("getImages", "Took: " + Long.toString(timer.getElapsedTime()));

        returnImages(images, result);

      }
    }).start();

    /*
     * } else { int i = 0; while (i < nToRead && cursor.moveToNext()) { i++;
     * Log.d("Channel", "loading next image"); String absolutePathOfImage =
     * cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA));
     * images.add(absolutePathOfImage); Log.d("Channel", "Returning: " +
     * absolutePathOfImage); } Log.d("Channel", "About to return");
     * result.success(images); }
     */
  }


  private void returnImages(final ArrayList<byte[]> images, final Result result) {
    new Handler(Looper.getMainLooper()).post(new Runnable() {
      @Override
      public void run() {
        result.success(images);
      }
    });
  }

  private void getGalleryImages(final MethodCall call, final Result result) {

    new Thread(new Runnable() {
      @Override
      public void run() {

        Stopwatch timer = new Stopwatch();
        timer.start();

        final int nToRead = call.argument("nToRead");
        final int startingIndex = call.argument("startingIndex");
        Integer targetWidth = call.argument("targetWidth");
        Integer targetHeight = call.argument("targetHeight");
        final Boolean newCursor = call.argument("newCursor");

        final ArrayList<byte[]> images = new ArrayList<byte[]>();

        if (cursor == null || newCursor) {
          Log.d("getImages", "New cursor");
          Uri uri = android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
          String[] projection = { MediaStore.MediaColumns.DATA };
          cursor = activity.getContentResolver().query(uri, projection, null, null,
              MediaStore.MediaColumns.DATE_ADDED + "  desc");
        }

        cursor.moveToPosition(startingIndex - 1);

        int i = 0;
        while (i < nToRead && cursor.moveToNext()) {
          i++;
          String absolutePathOfImage = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA));
          if (targetWidth == 0 || targetHeight == 0 || targetWidth == null || targetHeight == null) {
            Bitmap original = BitmapFactory.decodeFile(absolutePathOfImage);
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            original.compress(Bitmap.CompressFormat.JPEG, 70, stream);
            images.add(stream.toByteArray());
          } else {
            Bitmap original = BitmapFactory.decodeFile(absolutePathOfImage);
            float originalWidth = original.getWidth();
            float originalHeight = original.getHeight();


            Log.d("getImages", "original width: " + originalWidth + " original height : " + originalHeight);

            if (originalWidth > originalHeight) {
              // landscape
              targetHeight = (int) (originalHeight*targetWidth/originalWidth);
            } else if (originalHeight > originalWidth) {
              // portrait
              targetWidth = (int) (originalWidth*targetHeight/originalHeight);
            } 

            Log.d("getImages", "about to resize with width: " + targetWidth + " and height " + targetHeight);
            Bitmap out = Bitmap.createScaledBitmap(original, targetWidth, targetHeight, false);
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            out.compress(Bitmap.CompressFormat.JPEG, 70, stream);
            images.add(stream.toByteArray());
          }
        }
        timer.stop();
        Log.d("getImages", "Took: " + Long.toString(timer.getElapsedTime()));

        returnImages(images, result);

      }
    }).start();

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

    if (call.method.equals("resetCursor")) {
      this.cursor.close();
      this.cursor = null;
    }
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
