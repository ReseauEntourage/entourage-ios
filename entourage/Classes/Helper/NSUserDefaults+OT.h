

#import <Foundation/Foundation.h>

@class OTUser;

static NSString *const kEncounterDisclaimer = @"kEncounterDisclaimer";
static NSString *const kEntourageDisclaimer = @"kEntourgageDisclaimer";
extern NSString *const kTutorialDone;

@interface NSUserDefaults (OT)

@property (nonatomic, strong) OTUser *currentUser;
@property (nonatomic, strong) OTUser *temporaryUser;

+ (BOOL)wasEncounterDisclaimerAccepted;
+ (BOOL)wasEntourageDisclaimerAccepted;
- (BOOL)isTutorialCompleted;

@end
