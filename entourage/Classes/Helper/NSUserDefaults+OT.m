
#import "OTUser.h"

#import "NSUserDefaults+OT.h"

static NSString *const kUser = @"kUser";
static NSString *const kTemporaryUser = @"kTemporaryUser";

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

+ (BOOL)wasDisclaimerAccepted {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDisclaimer];
}


@end
