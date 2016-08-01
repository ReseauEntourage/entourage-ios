

#import <Foundation/Foundation.h>

@class OTUser;

static NSString *const kDisclaimer   = @"kDisclaimer";

@interface NSUserDefaults (OT)

@property (nonatomic, strong) OTUser *currentUser;
@property (nonatomic, strong) OTUser *temporaryUser;

+ (BOOL)wasDisclaimerAccepted;

@end
