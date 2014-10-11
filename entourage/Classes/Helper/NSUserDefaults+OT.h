

#import <Foundation/Foundation.h>

@class OTUser;

@interface NSUserDefaults (OT)

@property (nonatomic, strong) OTUser *currentUser;

@end
