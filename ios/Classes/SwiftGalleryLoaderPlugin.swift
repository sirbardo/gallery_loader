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
        else if (call.method == "getNumberOfImages"){
            DispatchQueue.main.async {
                print("Hi from Swift")
                NSLog("in swift! here we are!")
                let imgManager = PHImageManager.default()
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
                print("qui in swift")
                NSLog("passo due")
                let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                result(fetchResult.count)
            }
        }
        else if (call.method == "getGalleryImages") {
            var startingIndex : Int = 0
            var nToRead : Int = 1
            var targetWidth : Double = 0.0;
            var targetHeight : Double = 0.0;
            if let args = call.arguments {
                if let myArgs = args as? [String: Any]{
                    nToRead = myArgs["nToRead"] != nil ? myArgs["nToRead"] as! Int : 1
                    startingIndex = myArgs["startingIndex"] != nil ? myArgs["startingIndex"] as! Int : 0
                    targetWidth = myArgs["targetWidth"] != nil ? myArgs["targetWidth"] as! Double : 0.0
                    targetHeight = myArgs["targetHeight"] != nil ? myArgs["targetHeight"] as! Double : 0.0
                }
            } else {
                nToRead = 1;
                startingIndex = 0;
            }
        
            DispatchQueue.main.async {
                
                let imgManager = PHImageManager.default()
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                
                let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                var imagesToReturn = [String]()
                
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

                    imgManager.requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFit, options: PHImageRequestOptions(), resultHandler:{(image, info) in
                        
                        if image != nil {
                            var imageData: Data?
                            if let cgImage = image!.cgImage, cgImage.renderingIntent == .defaultIntent {
                                imageData = UIImageJPEGRepresentation(image!, 0.8)
                            }
                            else {
                                imageData = UIImagePNGRepresentation(image!)
                            }
                            let guid = ProcessInfo.processInfo.globallyUniqueString;
                            let tmpFile = String(format: "gallery_loader%@.jpg", guid);
                            let tmpDirectory = NSTemporaryDirectory();
                            let tmpPath = (tmpDirectory as NSString).appendingPathComponent(tmpFile);
                            if(FileManager.default.createFile(atPath: tmpPath, contents: imageData, attributes: [:])) {
                                imagesToReturn.append(tmpPath)
                            }
                        }
                        i += 1
                        if i == (nToRead) {
                            result(imagesToReturn)
                        }
                    })
                }
            }
        }  }
}
