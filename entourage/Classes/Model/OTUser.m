//
//  OTUser.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTUser.h"

#import "NSDictionary+Parsing.h"

NSString *const kKeySid = @"sid";
NSString *const kKeyEmail = @"email";
NSString *const kKeyFirstname = @"first_name";
NSString *const kKeyLastname = @"last_name";
NSString *const kKeyToken = @"token";

@implementation OTUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self)
	{
		_sid = [dictionary numberForKey:kKeySid];
		_email = [dictionary stringForKey:kKeyEmail];
        _firstName = [dictionary stringForKey:kKeyFirstname];
        _lastName = [dictionary stringForKey:kKeyLastname];
		_token = [dictionary stringForKey:kKeyToken];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:self.sid forKey:kKeySid];
	[encoder encodeObject:self.email forKey:kKeyEmail];
    [encoder encodeObject:self.firstName forKey:kKeyFirstname];
    [encoder encodeObject:self.lastName forKey:kKeyLastname];
	[encoder encodeObject:self.token forKey:kKeyToken];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init]))
	{
		self.sid = [decoder decodeObjectForKey:kKeySid];
		self.email = [decoder decodeObjectForKey:kKeyEmail];
        self.firstName = [decoder decodeObjectForKey:kKeyFirstname];
        self.lastName = [decoder decodeObjectForKey:kKeyLastname];
        self.token = [decoder decodeObjectForKey:kKeyToken];
	}
	return self;
}

@end
