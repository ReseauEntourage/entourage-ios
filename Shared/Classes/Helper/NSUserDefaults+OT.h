

#import <Foundation/Foundation.h>

@class OTUser;
@class OTTour;
@class OTSavedFilter;
@class OTSavedMyEntouragesFilter;
@class OTTourPoint;

extern NSString *const kTutorialDone;

@interface NSUserDefaults (OT)

@property (nonatomic, strong) OTUser *currentUser;
@property (nonatomic, strong) OTUser *temporaryUser;
@property (nonatomic, strong) OTTour *currentOngoingTour;
@property (nonatomic, assign) BOOL autoTutorialShown;
@property (nonatomic, strong) OTSavedFilter *savedNewsfeedsFilter;
@property (nonatomic, strong) OTSavedMyEntouragesFilter *savedMyEntouragesFilter;
@property (nonatomic, strong) NSArray *tourPoints;

- (BOOL)isTutorialCompleted;
- (BOOL)isTourOngoing;
- (void)setCompleteFirstLogin;
- (BOOL)isFirstLogin;

@end
