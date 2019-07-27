#import "GalleryLoaderPlugin.h"
#import <gallery_loader/gallery_loader-Swift.h>

@implementation GalleryLoaderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGalleryLoaderPlugin registerWithRegistrar:registrar];
}
@end
