

#import <Foundation/Foundation.h>

@class OTUser;

extern NSString *const kTutorialDone;

@interface NSUserDefaults (OT)

@property (nonatomic, strong) OTUser *currentUser;
@property (nonatomic, strong) OTUser *temporaryUser;
@property (nonatomic, assign) BOOL autoTutorialShown;
@property (nonatomic, assign) BOOL entourageFilterEnabled;

- (BOOL)isTutorialCompleted;

@end
