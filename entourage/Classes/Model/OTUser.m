//
//  OTUser.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTUser.h"

#import "NSDictionary+Parsing.h"

NSString *const kKeySid = @"id";
NSString *const kKeyEmail = @"email";
NSString *const kKeyFirstname = @"first_name";
NSString *const kKeyLastname = @"last_name";
NSString *const kKeyDisplayName = @"display_name";
NSString *const kKeyUserPhone = @"phone";
NSString *const kKeyPassword = @"sms_code";
NSString *const kKeyAvatarURL = @"avatar_url";
NSString *const kKeyToken = @"token";
NSString *const kKeyStats = @"stats";
NSString *const kKeyTourCount = @"tour_count";
NSString *const kKeyEncounterCount = @"encounter_count";
NSString *const kKeyOrganization =@"organization";

@implementation OTUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self)
	{
		_sid = [dictionary numberForKey:kKeySid];
		_email = [dictionary stringForKey:kKeyEmail];
        _avatarURL = [dictionary stringForKey:kKeyAvatarURL];
        _firstName = [dictionary stringForKey:kKeyFirstname];
        _lastName = [dictionary stringForKey:kKeyLastname];
        _displayName = [dictionary stringForKey:kKeyDisplayName];
        _phone = [dictionary stringForKey:kKeyUserPhone];
		_token = [dictionary stringForKey:kKeyToken];
        _tourCount = [[dictionary objectForKey:kKeyStats] numberForKey:kKeyTourCount defaultValue:0];
        _encounterCount = [[dictionary objectForKey:kKeyStats] numberForKey:kKeyEncounterCount];
        _organization = [[OTOrganization alloc] initWithDictionary:[dictionary objectForKey:kKeyOrganization]];
	}
	return self;
}

- (NSDictionary *)dictionaryForWebservice
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if (self.firstName != nil) {
        [dictionary setObject:self.firstName forKey:kKeyFirstname];
    }
    if (self.lastName != nil) {
        [dictionary setObject:self.lastName forKey:kKeyLastname];
    }
    if (self.email != nil) {
        [dictionary setObject:self.email forKey:kKeyEmail];
    }
    if (self.password != nil) {
        [dictionary setObject:self.password forKey:kKeyPassword];
    }
    
    return dictionary;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:self.sid forKey:kKeySid];
	[encoder encodeObject:self.email forKey:kKeyEmail];
    [encoder encodeObject:self.avatarURL forKey:kKeyAvatarURL];
    [encoder encodeObject:self.firstName forKey:kKeyFirstname];
    [encoder encodeObject:self.lastName forKey:kKeyLastname];
    [encoder encodeObject:self.displayName forKey:kKeyDisplayName];
    [encoder encodeObject:self.phone forKey:kKeyUserPhone];
	[encoder encodeObject:self.token forKey:kKeyToken];
    [encoder encodeObject:self.tourCount forKey:kKeyTourCount];
    [encoder encodeObject:self.encounterCount forKey:kKeyEncounterCount];
    [encoder encodeObject:self.organization forKey:kKeyOrganization];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init]))
	{
		self.sid = [decoder decodeObjectForKey:kKeySid];
		self.email = [decoder decodeObjectForKey:kKeyEmail];
        self.avatarURL = [decoder decodeObjectForKey:kKeyAvatarURL];
        self.firstName = [decoder decodeObjectForKey:kKeyFirstname];
        self.lastName = [decoder decodeObjectForKey:kKeyLastname];
        self.displayName = [decoder decodeObjectForKey:kKeyDisplayName];
        self.phone = [decoder decodeObjectForKey:kKeyUserPhone];
        self.token = [decoder decodeObjectForKey:kKeyToken];
        self.tourCount = [decoder decodeObjectForKey:kKeyTourCount];
        self.encounterCount = [decoder decodeObjectForKey:kKeyEncounterCount];
        self.organization = [decoder decodeObjectForKey:kKeyOrganization];
	}
	return self;
}

- (NSString *)fullname
{
    return [NSString stringWithFormat:@"%@ %@",_firstName.capitalizedString, _lastName.capitalizedString];
}

@end
