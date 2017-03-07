
#import "OTUser.h"

#import "NSUserDefaults+OT.h"

static NSString *const kUser = @"kUser";
static NSString *const kTemporaryUser = @"kTemporaryUser";
static NSString *const kAutoTutorialComplete = @"kAutoTutorialComplete";
static NSString *const kEntourageFilterEnabled = @"kEntourageFilterEnabled";

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

- (OTUser *)currentUser
{
	NSData *encodedObject = [self objectForKey:kUser];
	OTUser *user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
	return user;
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

- (BOOL)entourageFilterEnabled {
    NSNumber *enabled = [self objectForKey:kEntourageFilterEnabled];
    return enabled == nil ? NO : enabled.boolValue;
}

- (void)setEntourageFilterEnabled:(BOOL)entourageFilterEnabled {
    [self setObject:[NSNumber numberWithBool:entourageFilterEnabled] forKey:kEntourageFilterEnabled];
}

- (BOOL)isTutorialCompleted {
    NSMutableArray *loggedNumbers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTutorialDone]];
    return [loggedNumbers containsObject:[self.currentUser phone]];
}

@end
