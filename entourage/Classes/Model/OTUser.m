//
//  OTUser.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTUser.h"
#import "OTApiKeys.h"
#import "NSDictionary+Parsing.h"

NSString *const kKeySid = @"id";
NSString *const kKeyType = @"user_type";
NSString *const kKeyEmail = @"email";
NSString *const kKeyDisplayName = @"display_name";
NSString *const kKeyUserPhone = @"phone";
NSString *const kKeyPassword = @"sms_code";
NSString *const kKeyAvatarURL = @"avatar_url";
NSString *const kKeyAvatarKey = @"avatar_key";
NSString *const kKeyToken = @"token";
NSString *const kKeyStats = @"stats";
NSString *const kKeyTourCount = @"tour_count";
NSString *const kKeyEntourageCount = @"entourage_count";
NSString *const kKeyEncounterCount = @"encounter_count";
NSString *const kKeyOrganization = @"organization";

@implementation OTUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
  self = [super init];
  if (self)
  {
    _sid = [dictionary numberForKey:kKeySid];
    _type = [dictionary stringForKey:kKeyType];
    _email = [dictionary stringForKey:kKeyEmail];
    _avatarURL = [dictionary stringForKey:kKeyAvatarURL];
    _firstName = [dictionary stringForKey:kWSKeyFirstname];
    _lastName = [dictionary stringForKey:kWSKeyLastname];
    _displayName = [dictionary stringForKey:kKeyDisplayName];
    _phone = [dictionary stringForKey:kKeyUserPhone];
    _token = [dictionary stringForKey:kKeyToken];
    _tourCount = [[dictionary objectForKey:kKeyStats] numberForKey:kKeyTourCount defaultValue:0];
    _entourageCount = [[dictionary objectForKey:kKeyStats] numberForKey:kKeyEntourageCount defaultValue:0];
    _encounterCount = [[dictionary objectForKey:kKeyStats] numberForKey:kKeyEncounterCount];
    _organization = [[OTOrganization alloc] initWithDictionary:[dictionary objectForKey:kKeyOrganization]];
  }
  return self;
}

- (NSDictionary *)dictionaryForWebservice
{
  NSMutableDictionary *dictionary = [NSMutableDictionary new];
  if (self.firstName != nil) {
    [dictionary setObject:self.firstName forKey:kWSKeyFirstname];
  }
  if (self.lastName != nil) {
    [dictionary setObject:self.lastName forKey:kWSKeyLastname];
  }
  if (self.email != nil) {
    [dictionary setObject:self.email forKey:kKeyEmail];
  }
  if (self.password != nil) {
    [dictionary setObject:self.password forKey:kKeyPassword];
  }
  if(self.avatarKey != nil) {
    [dictionary setObject:self.avatarKey forKey:kKeyAvatarKey];
  }

  return dictionary;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.sid forKey:kKeySid];
    [encoder encodeObject:self.type forKey:kKeyType];
    [encoder encodeObject:self.email forKey:kKeyEmail];
    [encoder encodeObject:self.avatarURL forKey:kKeyAvatarURL];
    [encoder encodeObject:self.firstName forKey:kWSKeyFirstname];
    [encoder encodeObject:self.lastName forKey:kWSKeyLastname];
    [encoder encodeObject:self.displayName forKey:kKeyDisplayName];
    [encoder encodeObject:self.phone forKey:kKeyUserPhone];
    [encoder encodeObject:self.token forKey:kKeyToken];
    [encoder encodeObject:self.tourCount forKey:kKeyTourCount];
    [encoder encodeObject:self.entourageCount forKey:kKeyEntourageCount];
    [encoder encodeObject:self.encounterCount forKey:kKeyEncounterCount];
    [encoder encodeObject:self.organization forKey:kKeyOrganization];
}

- (id)initWithCoder:(NSCoder *)decoder
{
  if ((self = [super init]))
  {
    self.sid = [decoder decodeObjectForKey:kKeySid];
    self.type = [decoder decodeObjectForKey:kKeyType];
    self.email = [decoder decodeObjectForKey:kKeyEmail];
    self.avatarURL = [decoder decodeObjectForKey:kKeyAvatarURL];
    self.firstName = [decoder decodeObjectForKey:kWSKeyFirstname];
    self.lastName = [decoder decodeObjectForKey:kWSKeyLastname];
    self.displayName = [decoder decodeObjectForKey:kKeyDisplayName];
    self.phone = [decoder decodeObjectForKey:kKeyUserPhone];
    self.token = [decoder decodeObjectForKey:kKeyToken];
    self.tourCount = [decoder decodeObjectForKey:kKeyTourCount];
    self.entourageCount = [decoder decodeObjectForKey:kKeyEntourageCount];
    self.encounterCount = [decoder decodeObjectForKey:kKeyEncounterCount];
    self.organization = [decoder decodeObjectForKey:kKeyOrganization];
  }
  return self;
}

#pragma mark - Helper functions

- (BOOL)isPro
{
    return [USER_TYPE_PRO isEqualToString:self.type];
}

@end
