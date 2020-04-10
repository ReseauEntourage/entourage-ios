// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TargetConditionals.h"

#if !TARGET_OS_TV

#import "FBSDKModelManager.h"

#import "FBSDKAddressFilterManager.h"
#import "FBSDKAddressInferencer.h"
#import "FBSDKEventInferencer.h"
#import "FBSDKFeatureExtractor.h"
#import "FBSDKFeatureManager.h"
#import "FBSDKGraphRequest.h"
#import "FBSDKGraphRequestConnection.h"
#import "FBSDKSettings.h"
#import "FBSDKSuggestedEventsIndexer.h"
#import "FBSDKTypeUtility.h"
#import "FBSDKMLMacros.h"

static NSString *_directoryPath;
static NSMutableDictionary<NSString *, id> *_modelInfo;

NS_ASSUME_NONNULL_BEGIN

@implementation FBSDKModelManager

#pragma mark - Public methods

+ (void)enable
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    // If the languageCode could not be fetched successfully, it's regarded as "en" by default.
    if (languageCode && ![languageCode isEqualToString:@"en"]) {
      return;
    }

    NSString *dirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:FBSDK_ML_MODEL_PATH];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
      [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:NULL error:NULL];
    }
    _directoryPath = dirPath;
    _modelInfo = [[NSUserDefaults standardUserDefaults] objectForKey:MODEL_INFO_KEY];

    // fetch api
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"%@/model_asset", [FBSDKSettings appID]]];

    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
      if (error) {
        return;
      }
      NSDictionary<NSString *, id> *resultDictionary = [FBSDKTypeUtility dictionaryValue:result];
      NSDictionary<NSString *, id> *modelInfo = [self convertToDictionary:resultDictionary[MODEL_DATA_KEY]];
      if (!modelInfo) {
        return;
      }
      // update cache
      _modelInfo = [modelInfo mutableCopy];
      [self processMTML];
      [[NSUserDefaults standardUserDefaults] setObject:_modelInfo forKey:MODEL_INFO_KEY];

      [FBSDKFeatureManager checkFeature:FBSDKFeatureMTML completionBlock:^(BOOL enabled) {
        if (enabled) {
          [self checkFeaturesAndExecuteForMTML];
        } else {
          [self checkFeaturesAndExecute];
        }
      }];
    }];
  });
}

+ (nullable NSDictionary *)getRulesForKey:(NSString *)useCase
{
  NSDictionary<NSString *, id> *model = [_modelInfo objectForKey:useCase];
  if (model && model[VERSION_ID_KEY]) {
    NSString *filePath = [_directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.rules", useCase, model[VERSION_ID_KEY]]];
    if (filePath) {
      NSData *ruelsData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
      NSDictionary *rules = [NSJSONSerialization JSONObjectWithData:ruelsData options:0 error:nil];
      return rules;
    }
  }
  return nil;
}

+ (nullable NSData *)getWeightsForKey:(NSString *)useCase
{
  if (!_modelInfo || !_directoryPath) {
    return nil;
  }
  NSDictionary<NSString *, id> *model = [_modelInfo objectForKey:useCase];
  if (model && model[VERSION_ID_KEY]) {
    NSString *path = [_directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.weights", useCase, model[VERSION_ID_KEY]]];
    if (!path) {
      return nil;
    }
    return [NSData dataWithContentsOfFile:path
                                  options:NSDataReadingMappedIfSafe
                                    error:nil];
  }
  return nil;
}

#pragma mark - Private methods

+ (void)processMTML
{
  NSString *mtmlAssetUri = nil;
  NSNumber *mtmlVersionId = 0;
  for (NSString *useCase in _modelInfo) {
    NSDictionary<NSString *, id> *model = _modelInfo[useCase];
    if ([useCase hasPrefix:MTMLKey]) {
      mtmlAssetUri = model[ASSET_URI_KEY];
      mtmlVersionId = model[VERSION_ID_KEY];
    }
  }
  if (mtmlAssetUri && [mtmlVersionId compare:[NSNumber numberWithInt:0]] > 0) {
    _modelInfo[MTMLKey] = @{
      USE_CASE_KEY: MTMLKey,
      ASSET_URI_KEY: mtmlAssetUri,
      VERSION_ID_KEY: mtmlVersionId,
    };
  }
}

+ (void)checkFeaturesAndExecuteForMTML
{
  [self getModelAndRules:MTMLKey onSuccess:^() {
    if ([FBSDKFeatureManager isEnabled:FBSDKFeatureSuggestedEvents]) {
      [self getModelAndRules:MTMLTaskAppEventPredKey onSuccess:^() {
        [FBSDKEventInferencer loadWeightsForKey:MTMLKey];
        [FBSDKFeatureExtractor loadRulesForKey:MTMLTaskAppEventPredKey];
        [FBSDKSuggestedEventsIndexer enable];
      }];
    }

    if ([FBSDKFeatureManager isEnabled:FBSDKFeaturePIIFiltering]) {
      [self getModelAndRules:MTMLTaskAddressDetectKey onSuccess:^() {
        [FBSDKAddressInferencer loadWeightsForKey:MTMLKey];
        [FBSDKAddressInferencer initializeDenseFeature];
        [FBSDKAddressFilterManager enable];
      }];
    }
  }];
}

+ (void)checkFeaturesAndExecute
{
  if ([FBSDKFeatureManager isEnabled:FBSDKFeatureSuggestedEvents]) {
    [self getModelAndRules:SUGGEST_EVENT_KEY onSuccess:^() {
      [FBSDKEventInferencer loadWeightsForKey:SUGGEST_EVENT_KEY];
      [FBSDKFeatureExtractor loadRulesForKey:SUGGEST_EVENT_KEY];
      [FBSDKSuggestedEventsIndexer enable];
    }];
  }

  if ([FBSDKFeatureManager isEnabled:FBSDKFeaturePIIFiltering]) {
    [self getModelAndRules:ADDRESS_FILTERING_KEY onSuccess:^() {
      [FBSDKAddressInferencer loadWeightsForKey:ADDRESS_FILTERING_KEY];
      [FBSDKAddressInferencer initializeDenseFeature];
      [FBSDKAddressFilterManager enable];
    }];
  }
}

+ (void)getModelAndRules:(NSString *)useCaseKey
               onSuccess:(FBSDKDownloadCompletionBlock)handler
{
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_group_t group = dispatch_group_create();

  NSDictionary<NSString *, id> *model = [_modelInfo objectForKey:useCaseKey];
  if (!model || !_directoryPath) {
      return;
  }

  // clear old model files
  NSArray<NSString *> *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_directoryPath error:nil];
  NSString *prefixWithVersion = [NSString stringWithFormat:@"%@_%@", useCaseKey, model[VERSION_ID_KEY]];

  for (NSString *file in files) {
    if ([file hasPrefix:useCaseKey] && ![file hasPrefix:prefixWithVersion]) {
      [[NSFileManager defaultManager] removeItemAtPath:[_directoryPath stringByAppendingPathComponent:file] error:nil];
    }
  }

  // download model asset only if not exist before
  NSString *assetUrlString = [model objectForKey:ASSET_URI_KEY];
  NSString *assetFilePath;
  if (assetUrlString.length > 0) {
    NSString *fileName = useCaseKey;
    if ([useCaseKey hasPrefix:MTMLKey]) {
      // all mtml tasks share the same weights file
      fileName = MTMLKey;
    }
    assetFilePath = [_directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.weights", fileName, model[VERSION_ID_KEY]]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:assetFilePath] == false) {
      [self download:assetUrlString filePath:assetFilePath queue:queue group:group];
    }
  }

  // download rules
  NSString *rulesUrlString = [model objectForKey:RULES_URI_KEY];
  NSString *rulesFilePath;
  // rules are optional and rulesUrlString may be empty
  if (rulesUrlString.length > 0) {
    rulesFilePath = [_directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.rules", useCaseKey, model[VERSION_ID_KEY]]];
    [self download:rulesUrlString filePath:rulesFilePath queue:queue group:group];
  }
  dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    if (handler) {
      if ([[NSFileManager defaultManager] fileExistsAtPath:assetFilePath] && (!rulesUrlString || (rulesUrlString && [[NSFileManager defaultManager] fileExistsAtPath:rulesFilePath]))) {
          handler();
      }
    }
  });
}

+ (void)download:(NSString *)urlString
        filePath:(NSString *)filePath
           queue:(dispatch_queue_t)queue
           group:(dispatch_group_t)group
{
  if (!filePath || [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    return;
  }
  dispatch_group_async(group, queue, ^{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if (urlData) {
      [urlData writeToFile:filePath atomically:YES];
    }
  });
}

+ (nullable NSMutableDictionary<NSString *, id> *)convertToDictionary:(NSArray<NSDictionary<NSString *, id> *> *)models
{
  if ([models count] == 0) {
    return nil;
  }
  NSMutableDictionary<NSString *, id> *modelInfo = [NSMutableDictionary dictionary];
  for (NSDictionary<NSString *, id> *model in models) {
    if (model[USE_CASE_KEY]) {
      [modelInfo addEntriesFromDictionary:@{model[USE_CASE_KEY]:model}];
    }
  }
  return modelInfo;
}

@end

NS_ASSUME_NONNULL_END

#endif
