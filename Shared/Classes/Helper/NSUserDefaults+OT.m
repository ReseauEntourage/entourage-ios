
#import "OTUser.h"
#import "OTTour.h"
#import "OTTourPoint.h"

#import "NSUserDefaults+OT.h"

static NSString *const kUser = @"kUser";
static NSString *const kTemporaryUser = @"kTemporaryUser";
static NSString *const kAutoTutorialComplete = @"kAutoTutorialComplete";
static NSString *const kNewsfeedsFilter = @"kNewsfeedsFilter_";
static NSString *const kMyEntouragesFilter = @"kMyEntouragesFilter_";
static NSString *const kTourOngoing = @"kTour";
static NSString *const kTourPoints = @"kTourPoints";

@implementation NSUserDefaults (OT)

/********************************************************************************/
#pragma mark - User Settings

- (void)setCurrentUser:(OTUser *)user
{
    if (user)
	{
		NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
		[self setObject:encodedObject forKey:kUser];
	}
	else
	{
		[self removeObjectForKey:kUser];
	}
	[self synchronize];
}

- (void)setCurrentOngoingTour:(OTTour *)tour {
    if (tour)
    {
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:tour];
        [self setObject:encodedObject forKey:kTourOngoing];
    }
    else
    {
        [self removeObjectForKey:kTourOngoing];
    }
    [self synchronize];
}

- (void)setTourPoints:(NSArray *)tourPoints {
    if (tourPoints)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tourPoints];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kTourPoints];
    }
    else
    {
        [self removeObjectForKey:kTourPoints];
    }
    [self synchronize];
}

- (OTUser *)currentUser
{
	NSData *encodedObject = [self objectForKey:kUser];
	OTUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
	return user;
}

- (OTTour *)currentOngoingTour {
    NSData *encodedObject = [self objectForKey:kTourOngoing];
    OTTour *tour = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return tour;
}

- (NSArray *)tourPoints {
    NSData *encodedObject = [self objectForKey:kTourPoints];
    NSArray *tourPoints = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return tourPoints;
}

- (void)setTemporaryUser:(OTUser *)temporaryUser {
    if (temporaryUser)
    {
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:temporaryUser];
        [self setObject:encodedObject forKey:kTemporaryUser];
    }
    else
    {
        [self removeObjectForKey:kTemporaryUser];
    }
    [self synchronize];
}

- (OTUser *)temporaryUser {
    NSData *encodedObject = [self objectForKey:kTemporaryUser];
    OTUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return user;
}

- (void)setAutoTutorialShown:(BOOL)autoTutorialShown {
    NSMutableArray *loggedNumbers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kAutoTutorialComplete]];
    BOOL hasPhoneInNumbers = [loggedNumbers containsObject:self.currentUser.phone];
    if(hasPhoneInNumbers && !autoTutorialShown)
       [loggedNumbers removeObject:self.currentUser.phone];
    if(!hasPhoneInNumbers && autoTutorialShown)
        [loggedNumbers addObject:self.currentUser.phone];
    [[NSUserDefaults standardUserDefaults] setObject:loggedNumbers forKey:kAutoTutorialComplete];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)autoTutorialShown {
    NSMutableArray *numbersWithTutorial = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kAutoTutorialComplete]];
    return [numbersWithTutorial containsObject:self.currentUser.phone];
}

- (OTSavedFilter *)savedNewsfeedsFilter {
    NSString *key = [self keyForSavedFilter];
    NSData *encodedObject = [self objectForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
}

- (void)setSavedNewsfeedsFilter:(OTSavedFilter *)savedNewsfeedsFilter {
    NSString *key = [self keyForSavedFilter];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:savedNewsfeedsFilter];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)keyForSavedFilter {
    if (self.currentUser != nil)
        return [kNewsfeedsFilter stringByAppendingString:self.currentUser.sid.stringValue];
    return @"";
}

- (OTSavedMyEntouragesFilter *)savedMyEntouragesFilter {
    NSString *key = [self keyForSavedMyEntouragesFilter];
    NSData *encodedObject = [self objectForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
}

- (void)setSavedMyEntouragesFilter:(OTSavedMyEntouragesFilter *)savedMyentouragesFilter {
    NSString *key = [self keyForSavedMyEntouragesFilter];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:savedMyentouragesFilter];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)keyForSavedMyEntouragesFilter {
    return [kMyEntouragesFilter stringByAppendingString:self.currentUser.sid.stringValue];
}

- (BOOL)isTourOngoing {
    return YES;
}

- (BOOL)isTutorialCompleted {
    NSMutableArray *loggedNumbers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTutorialDone]];
    return [loggedNumbers containsObject:[self.currentUser phone]];
}

@end
