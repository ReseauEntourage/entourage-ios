

#import <Foundation/Foundation.h>

@class OTUser;

extern NSString *const kTutorialDone;

@interface NSUserDefaults (OT)

@property (nonatomic, strong) OTUser *currentUser;
@property (nonatomic, strong) OTUser *temporaryUser;

- (BOOL)isTutorialCompleted;

@end
