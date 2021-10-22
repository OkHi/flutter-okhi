#import "OkhiPlugin.h"
#if __has_include(<okhi/okhi-Swift.h>)
#import <okhi/okhi-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "okhi-Swift.h"
#endif

@implementation OkhiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftOkhiPlugin registerWithRegistrar:registrar];
}
@end
