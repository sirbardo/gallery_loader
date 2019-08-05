import Flutter
import UIKit
import Photos

public class SwiftGalleryLoaderPlugin: NSObject, FlutterPlugin {
    
    private var fetchResult : PHFetchResult<PHAsset>?


    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "gallery_loader", binaryMessenger: registrar.messenger())
        let instance = SwiftGalleryLoaderPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
        }
        else if (call.method == "getGalleryImages" || call.method == "getThumbnails"){

            print("Ciao")
            
            DispatchQueue.global(qos: .default).async {
            var startingIndex : Int = 0
            var nToRead : Int = 1
            var targetWidth : Int = 0;
            var targetHeight : Int = 0;
            var newCursor : Bool = false;
            if let args = call.arguments {
                if let myArgs = args as? [String: Any]{
                    nToRead = myArgs["nToRead"] != nil ? myArgs["nToRead"] as! Int : 1
                    startingIndex = myArgs["startingIndex"] != nil ? myArgs["startingIndex"] as! Int : 0
                    targetWidth = myArgs["targetWidth"] != nil ? myArgs["targetWidth"] as! Int : 0
                    targetHeight = myArgs["targetHeight"] != nil ? myArgs["targetHeight"] as! Int : 0
                    newCursor = myArgs["newCursor"] != nil ? myArgs["newCursor"] as! Bool : false
                }
            } else {
                nToRead = 1;
                startingIndex = 0;
            }
                
                
                if (call.method == "getThumbnails"){
                    targetHeight = 200
                    targetWidth = 200
                }
                
                if (newCursor || self.fetchResult == nil){
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                    self.fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                }
            
                let imgManager = PHImageManager.default()

            var imagesToReturn = [FlutterStandardTypedData]()
            var i = 0
            for index in startingIndex...startingIndex+nToRead-1
            {
                if (index > fetchResult?.count)
                    break
                let asset = self.fetchResult!.object(at: index) as PHAsset
                var size : CGSize;
                if (targetWidth != 0 && targetHeight != 0){
                    size = CGSize(width: targetWidth, height: targetHeight)
                }
                else {
                    size = PHImageManagerMaximumSize
                }
                
                let imgOptions = PHImageRequestOptions()
                imgOptions.isNetworkAccessAllowed = true
                imgOptions.isSynchronous = false
                
                imgManager.requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFit, options: imgOptions, resultHandler:{(image, info) in
                    if image != nil && !(info![PHImageResultIsDegradedKey]! as! Bool) {
                        var imageData: Data?
                        if let cgImage = image!.cgImage, cgImage.renderingIntent == .defaultIntent {
                            imageData = UIImageJPEGRepresentation(image!, 0.8)
                        }
                        else {
                            imageData = UIImagePNGRepresentation(image!)
                        }
                        imagesToReturn.append(FlutterStandardTypedData(bytes: imageData!));
                        i += 1
                        if i == (nToRead) {
                          result(imagesToReturn)
                        }
                    }
                })
            }}
        }
        else if (call.method == "getNumberOfImages"){
            DispatchQueue.main.async {
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
                let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                result(fetchResult.count)
            }
        }
    }
}
