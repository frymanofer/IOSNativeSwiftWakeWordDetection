// ios/WakeWordNative.mm
#import "WakeWordNative.h"
#import <Foundation/Foundation.h>

// Make sure your Swift framework/module exposes these:
// - KeyWordsDetection (Swift class @objc public class KeyWordsDetection)
// - KeywordDetectionRNDelegate (Swift @objc public protocol KeywordDetectionRNDelegate)
// - AudioSessionAndDuckingManager (Swift @objc public class/Singleton)
#import "KeyWordsDetection.h"

static NSString * const kWakeWordDetectedNotification = @"WakeWordDetectedNotification";

@interface KeyWordsDetectionWrapper : NSObject <KeywordDetectionRNDelegate>

@property (nonatomic, strong) KeyWordsDetection *keyWordsDetection;
@property (nonatomic, strong) NSString *instanceId;

/// Optional: hook for native callback without RN
@property (nonatomic, copy) void (^onEvent)(NSDictionary *eventInfo);

- (instancetype)initWithInstanceId:(NSString *)instanceId
                         modelName:(NSString *)modelName
                         modelPath:(NSString * _Nullable)modelPath
                         threshold:(float)threshold
                         bufferCnt:(NSInteger)bufferCnt
                         cancelEcho:(BOOL)cancelEcho
                             error:(NSError * _Nullable * _Nullable)error;

@end

@implementation KeyWordsDetectionWrapper

- (instancetype)initWithInstanceId:(NSString *)instanceId
                         modelName:(NSString *)modelName
                         modelPath:(NSString * _Nullable)modelPath
                         threshold:(float)threshold
                         bufferCnt:(NSInteger)bufferCnt
                        cancelEcho:(BOOL)cancelEcho
                             error:(NSError * _Nullable * _Nullable)error
{
  self = [super init];
  if (!self) return nil;

  _instanceId = instanceId;

  // NEW Swift constructor:
  // init(modelName: String, modelPath: String? = nil, threshold: Float, bufferCnt: Int, cancelEcho: Bool = false)
  //
  // ObjC selector becomes:
  // -initWithModelName:modelPath:threshold:bufferCnt:cancelEcho:error:
  _keyWordsDetection =
    [[KeyWordsDetection alloc] initWithModelName:modelName
                                      modelPath:(modelPath.length > 0 ? modelPath : nil)
                                     threshold:threshold
                                     bufferCnt:bufferCnt
                                    cancelEcho:cancelEcho
                                         error:error];

  if (error && *error) return nil;

  _keyWordsDetection.delegate = self;
  return self;
}

- (void)KeywordDetectionDidDetectEvent:(NSDictionary *)eventInfo
{
  NSMutableDictionary *mutableEventInfo = [eventInfo mutableCopy] ?: [NSMutableDictionary new];
  mutableEventInfo[@"instanceId"] = self.instanceId ?: @"";

  // 1) Optional direct callback
  if (self.onEvent) {
    self.onEvent([mutableEventInfo copy]);
  }

  // 2) Also publish as notification (native-friendly)
  [[NSNotificationCenter defaultCenter] postNotificationName:kWakeWordDetectedNotification
                                                      object:nil
                                                    userInfo:[mutableEventInfo copy]];
}

@end


@interface WakeWordNative ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, KeyWordsDetectionWrapper *> *instances;
@end

@implementation WakeWordNative

- (instancetype)init
{
  self = [super init];
  if (!self) return nil;
  _instances = [NSMutableDictionary new];
  return self;
}

#pragma mark - Instances

/// Create an instance.
/// modelPath behavior (matches your Swift init):
/// - nil/empty: loads "<modelName>.cml" and "first_layers.cml" from bundle (copied to Documents)
/// - if modelPath points to a .cml file: uses it as keyword model, and takes "first_layers.cml" from same folder
/// - else: treats modelPath as a directory containing "<modelName>.cml" and "first_layers.cml"
- (BOOL)createInstance:(NSString *)instanceId
             modelName:(NSString *)modelName
             modelPath:(NSString * _Nullable)modelPath
             threshold:(float)threshold
             bufferCnt:(NSInteger)bufferCnt
            cancelEcho:(BOOL)cancelEcho
                 error:(NSError * _Nullable * _Nullable)error
{
  if (instanceId.length == 0) {
    if (error) *error = [NSError errorWithDomain:@"WakeWordNative"
                                            code:100
                                        userInfo:@{NSLocalizedDescriptionKey:@"instanceId is empty"}];
    return NO;
  }

  if (self.instances[instanceId]) {
    if (error) *error = [NSError errorWithDomain:@"WakeWordNative"
                                            code:101
                                        userInfo:@{NSLocalizedDescriptionKey:
                                                     [NSString stringWithFormat:@"Instance already exists: %@", instanceId]}];
    return NO;
  }

  NSError *localErr = nil;
  KeyWordsDetectionWrapper *wrapper =
    [[KeyWordsDetectionWrapper alloc] initWithInstanceId:instanceId
                                               modelName:modelName
                                               modelPath:modelPath
                                               threshold:threshold
                                               bufferCnt:bufferCnt
                                              cancelEcho:cancelEcho
                                                   error:&localErr];

  if (localErr) {
    if (error) *error = localErr;
    return NO;
  }

  self.instances[instanceId] = wrapper;
  return YES;
}

- (void)destroyInstance:(NSString *)instanceId
{
  KeyWordsDetectionWrapper *wrapper = self.instances[instanceId];
  if (!wrapper) return;

  [wrapper.keyWordsDetection stopListening];
  [self.instances removeObjectForKey:instanceId];
}

#pragma mark - License

- (BOOL)setKeywordDetectionLicense:(NSString *)instanceId
                        licenseKey:(NSString *)licenseKey
                             error:(NSError * _Nullable * _Nullable)error
{
  KeyWordsDetectionWrapper *wrapper = self.instances[instanceId];
  if (!wrapper || !wrapper.keyWordsDetection) {
    if (error) *error = [NSError errorWithDomain:@"WakeWordNative"
                                            code:200
                                        userInfo:@{NSLocalizedDescriptionKey:
                                                     [NSString stringWithFormat:@"No instance found: %@", instanceId]}];
    return NO;
  }
  return [wrapper.keyWordsDetection setLicenseWithLicenseKey:licenseKey];
}

#pragma mark - Start/Stop

- (BOOL)startKeywordDetection:(NSString *)instanceId
                    setActive:(BOOL)setActive
                   duckOthers:(BOOL)duckOthers
               mixWithOthers:(BOOL)mixWithOthers
            defaultToSpeaker:(BOOL)defaultToSpeaker
                        error:(NSError * _Nullable * _Nullable)error
{
  KeyWordsDetectionWrapper *wrapper = self.instances[instanceId];
  if (!wrapper || !wrapper.keyWordsDetection) {
    if (error) *error = [NSError errorWithDomain:@"WakeWordNative"
                                            code:300
                                        userInfo:@{NSLocalizedDescriptionKey:
                                                     [NSString stringWithFormat:@"No instance found: %@", instanceId]}];
    return NO;
  }

  BOOL success = [wrapper.keyWordsDetection startListeningWithSetActive:setActive
                                                             duckOthers:duckOthers
                                                         mixWithOthers:mixWithOthers
                                                      defaultToSpeaker:defaultToSpeaker];

  if (!success && error) {
    *error = [NSError errorWithDomain:@"WakeWordNative"
                                 code:301
                             userInfo:@{NSLocalizedDescriptionKey:@"Failed to start detection (license invalid or already listening)"}];
  }
  return success;
}

- (void)stopKeywordDetection:(NSString *)instanceId
{
  KeyWordsDetectionWrapper *wrapper = self.instances[instanceId];
  if (!wrapper || !wrapper.keyWordsDetection) return;
  [wrapper.keyWordsDetection stopListening];
}

#pragma mark - Replace model (optional)

- (BOOL)replaceKeywordDetectionModel:(NSString *)instanceId
                          modelName:(NSString *)modelName
                          threshold:(float)threshold
                          bufferCnt:(NSInteger)bufferCnt
                              error:(NSError * _Nullable * _Nullable)error
{
  KeyWordsDetectionWrapper *wrapper = self.instances[instanceId];
  if (!wrapper || !wrapper.keyWordsDetection) {
    if (error) *error = [NSError errorWithDomain:@"WakeWordNative"
                                            code:400
                                        userInfo:@{NSLocalizedDescriptionKey:
                                                     [NSString stringWithFormat:@"No instance found: %@", instanceId]}];
    return NO;
  }

  NSError *localErr = nil;

  // Your Swift method is:
  // @objc public func replaceKeywordDetectionModel(modelName: String, threshold: Float, bufferCnt: Int) throws
  // Objective-C selector becomes:
  // -replaceKeywordDetectionModelWithModelName:threshold:bufferCnt:error:
  //
  // NOTE: If your generated selector name differs, adjust here to match the -Swift.h output.
  [wrapper.keyWordsDetection replaceKeywordDetectionModelWithModelName:modelName
                                                             threshold:threshold
                                                             bufferCnt:bufferCnt
                                                                 error:&localErr];

  if (localErr) {
    if (error) *error = localErr;
    return NO;
  }
  return YES;
}

#pragma mark - Info

- (NSString * _Nullable)getKeywordDetectionModel:(NSString *)instanceId
                                          error:(NSError * _Nullable * _Nullable)error
{
  KeyWordsDetectionWrapper *wrapper = self.instances[instanceId];
  if (!wrapper || !wrapper.keyWordsDetection) {
    if (error) *error = [NSError errorWithDomain:@"WakeWordNative"
                                            code:500
                                        userInfo:@{NSLocalizedDescriptionKey:
                                                     [NSString stringWithFormat:@"No instance found: %@", instanceId]}];
    return nil;
  }
  return [wrapper.keyWordsDetection getKeywordDetectionModel];
}

- (NSString * _Nullable)getRecordingWav:(NSString *)instanceId
                                  error:(NSError * _Nullable * _Nullable)error
{
  KeyWordsDetectionWrapper *wrapper = self.instances[instanceId];
  if (!wrapper || !wrapper.keyWordsDetection) {
    if (error) *error = [NSError errorWithDomain:@"WakeWordNative"
                                            code:501
                                        userInfo:@{NSLocalizedDescriptionKey:
                                                     [NSString stringWithFormat:@"No instance found: %@", instanceId]}];
    return nil;
  }
  return [wrapper.keyWordsDetection getRecordingWav];
}

#pragma mark - Audio ducking helpers (still native)

- (void)disableDucking { [AudioSessionAndDuckingManager.shared disableDucking]; }
- (void)initAudioSessAndDuckManage { [AudioSessionAndDuckingManager.shared initAudioSessAndDuckManage]; }
- (void)restartListeningAfterDucking { [AudioSessionAndDuckingManager.shared restartListeningAfterDucking]; }
- (void)enableAggressiveDucking { [AudioSessionAndDuckingManager.shared enableAggressiveDucking]; }
- (void)disableDuckingAndCleanup { [AudioSessionAndDuckingManager.shared disableDuckingAndCleanup]; }

@end
