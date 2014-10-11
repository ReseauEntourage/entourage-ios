

#import "NSUserDefaults+OT.h"

static NSString *const kUserMail   = @"kUserMail";
static NSString *const kUserSid   = @"kUserSid";

@implementation NSUserDefaults (OT)

/********************************************************************************/
#pragma mark - User Settings

- (void)setUserMail:(NSString *)userMail {
	if (userMail) {
		[self setObject:userMail forKey:kUserMail];
	}
	else {
		[self removeObjectForKey:kUserMail];
	}
	[self synchronize];
}

- (NSString *)userMail {
	return [self stringForKey:kUserMail];
}

- (void)setUserSid:(NSInteger)userId {
	if (userId) {
		[self setInteger:userId forKey:kUserSid];
	}
	else {
		[self removeObjectForKey:kUserSid];
	}
	[self synchronize];
}

- (NSInteger)userSid {
	return [self integerForKey:kUserSid];
}

@end
