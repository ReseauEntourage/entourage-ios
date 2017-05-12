

#import <Foundation/Foundation.h>

@class OTUser;
@class OTSavedFilter;

extern NSString *const kTutorialDone;

@interface NSUserDefaults (OT)

@property (nonatomic, strong) OTUser *currentUser;
@property (nonatomic, strong) OTUser *temporaryUser;
@property (nonatomic, assign) BOOL autoTutorialShown;
@property (nonatomic, strong) OTSavedFilter *savedNewsfeedsFilter;

- (BOOL)isTutorialCompleted;

@end
