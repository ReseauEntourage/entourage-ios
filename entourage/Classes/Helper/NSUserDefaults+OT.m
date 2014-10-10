//
//  NSUserDefaults+OT.m
//  LBC
//
//  Created by Guillaume Lagorce on 02/04/2014.
//  Copyright (c) 2014 BNP Paribas. All rights reserved.
//

#import "NSUserDefaults+OT.h"

static NSString *const kUserMail   = @"kUserMail";

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

@end
