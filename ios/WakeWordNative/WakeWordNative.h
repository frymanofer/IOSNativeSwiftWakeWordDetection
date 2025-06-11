//ios/WakeWordNative.h
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
//#import "porcuSafe-Swift.h" // Replace with your actual project name
#import <KeyWordDetection/KeyWordDetection-Swift.h>

@interface WakeWordNative : RCTEventEmitter <RCTBridgeModule, KeywordDetectionRNDelegate>
// @interface WakeWordNative : NSObject <RCTBridgeModule, KeywordDetectionRNDelegate>
//@interface WakeWordNative : RCTEventEmitter <RCTBridgeModule>
+ (void)sendEventWithName:(NSString *)name body:(id)body;
@end

/*

@interface WakeWordNative : RCTEventEmitter <RCTBridgeModule>
+ (instancetype)sharedInstance;
- (void)KeywordDetectionDidDetectEvent:(NSDictionary *)eventInfo;
@end
*/
