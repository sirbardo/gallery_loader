# gallery_loader

A flutter plugin to get paths of gallery images, both full-sized or at custom resolutions, from the native content providers. 

## Usage

### Install

Just add this repo to your pubspec.yaml, like this:

```yaml
gallery_loader:
   git: https://github.com/sirbardo/gallery_loader.git
```

Then, add the Permissions as explained below, and ask for permissions in your UI. I suggest using [permission_handler](https://pub.dev/packages/permission_handler) as a plugin for this.

#### Android

Add this line to your android/app/src/main/AndroidManifest.xml

```xml
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

#### iOS

Add these lines to your Info.plist

```xml
	<key>NSPhotoLibraryUsageDescription</key>
	<string>We need to use the camera roll for this example app</string>
```

### Using the plugin

Check the example app, but the main api is pretty obvious from this snippet:

```dart
  Future<List<String>> getImages(
      {total: 1, startingIndex: 0, width: 0, height: 0}) async {
    final images = await GalleryLoader.getGalleryImages(
        total: total,
        startingIndex: startingIndex,
        targetWidth: width,
        targetHeight: height);
    return images;
  }

  Future<void> getImageCount() async {
    int totalImages = await GalleryLoader.getNumberOfImages();
    setState(() {
      _totalImages = totalImages;
    });
  }
```
