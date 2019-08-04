import Flutter
import UIKit
import Photos

public class SwiftGalleryLoaderPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "gallery_loader", binaryMessenger: registrar.messenger())
        let instance = SwiftGalleryLoaderPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
        }
        else if (call.method == "getGalleryImages"){

            DispatchQueue.global(qos: .background).async {
            var startingIndex : Int = 0
            var nToRead : Int = 1
            var targetWidth : Int = 0;
            var targetHeight : Int = 0;
            if let args = call.arguments {
                if let myArgs = args as? [String: Any]{
                    nToRead = myArgs["nToRead"] != nil ? myArgs["nToRead"] as! Int : 1
                    startingIndex = myArgs["startingIndex"] != nil ? myArgs["startingIndex"] as! Int : 0
                    targetWidth = myArgs["targetWidth"] != nil ? myArgs["targetWidth"] as! Int : 0
                    targetHeight = myArgs["targetHeight"] != nil ? myArgs["targetHeight"] as! Int : 0
                }
            } else {
                nToRead = 1;
                startingIndex = 0;
            }
            
            
            let imgManager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
            
            let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
            var imagesToReturn = [FlutterStandardTypedData]()
            
            var i = 0
            
            var savedLocalIdentifiers = [String]()
            
            for index in startingIndex...startingIndex+nToRead-1
            {
                let asset = fetchResult.object(at: index) as PHAsset
                let localIdentifier = asset.localIdentifier
                savedLocalIdentifiers.append(localIdentifier)
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
                    if image != nil {
                        var imageData: Data?
                        if let cgImage = image!.cgImage, cgImage.renderingIntent == .defaultIntent {
                            imageData = UIImageJPEGRepresentation(image!, 0.8)
                        }
                        else {
                            imageData = UIImagePNGRepresentation(image!)
                        }
                        let guid = ProcessInfo.processInfo.globallyUniqueString;
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
                let imgManager = PHImageManager.default()
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
