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
NSString *const kKeyUuid = @"uuid";
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
NSString *const kKeyConversation = @"conversation";
NSString *const kKeyPartner = @"partner";
NSString *const kKeyRoles = @"roles";
NSString *const kKeyAnonymous = @"anonymous";
NSString *const kMemberships = @"memberships";
NSString *const kAddress = @"address";
NSString *const kFirebaseProperties = @"firebase_properties";

NSString *const kCoordinatorUserTag = @"coordinator";
NSString *const kNotValidatedUserTag = @"not_validated";
NSString *const kVisitorUserTag = @"visitor";
NSString *const kVisitedUserTag = @"visited";
NSString *const kEthicsCharterSignedTag = @"ethics_charter_signed";

@interface OTUser ()
@property (nonatomic, readwrite) NSString *uuid;
@property (nonatomic, readwrite) NSArray *memberships;
@property (nonatomic, readwrite) BOOL anonymous;
@end

@implementation OTUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _sid = [dictionary numberForKey:kKeySid];
        _uuid = [dictionary stringForKey:kKeyUuid];
        _type = [dictionary stringForKey:kKeyType];
        _email = [dictionary stringForKey:kKeyEmail];
        _avatarURL = [dictionary stringForKey:kKeyAvatarURL];
        _firstName = [dictionary stringForKey:kWSKeyFirstname];
        _lastName = [dictionary stringForKey:kWSKeyLastname];
        _about = [dictionary stringForKey:kWSKeyAboutMe];
        _displayName = [dictionary stringForKey:kKeyDisplayName];
        _phone = [dictionary stringForKey:kKeyUserPhone];
        _token = [dictionary stringForKey:kKeyToken];
        _tourCount = [[dictionary objectForKey:kKeyStats] numberForKey:kKeyTourCount defaultValue:0];
        _entourageCount = [[dictionary objectForKey:kKeyStats] numberForKey:kKeyEntourageCount defaultValue:0];
        _encounterCount = [[dictionary objectForKey:kKeyStats] numberForKey:kKeyEncounterCount];
        _organization = [[OTOrganization alloc] initWithDictionary:[dictionary objectForKey:kKeyOrganization]];
        _partner = [[OTAssociation alloc] initWithDictionary:[dictionary objectForKey:kKeyPartner]];
        _anonymous = [dictionary boolForKey:kKeyAnonymous defaultValue:NO];
        _firebaseProperties = [self sanitizeFirebaseProperties:[dictionary objectForKey:kFirebaseProperties]];
        
        if ([[dictionary allKeys] containsObject:kKeyConversation]) {
            _conversation = [[OTConversation alloc] initWithDictionary:[dictionary objectForKey:kKeyConversation]];
        }
        
        if ([[dictionary allKeys] containsObject:kKeyRoles]) {
            _roles = [dictionary arrayWithObjectsOfClass:[NSString class] forKey:kKeyRoles];
        }
        
        if ([[dictionary allKeys] containsObject:kAddress]) {
            _address = [[OTAddress alloc] initWithDictionary:[dictionary objectForKey:kAddress]];
        }
        
        NSArray *membershipArray = [dictionary objectForKey:kMemberships];
        NSMutableArray *userMemberships = [[NSMutableArray alloc] init];
        for (NSDictionary *membershipDict in membershipArray) {
            OTUserMembership *userMembership = [[OTUserMembership alloc] initWithDictionary:membershipDict];
            [userMemberships addObject:userMembership];
        }
        _memberships = userMemberships;
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
    if(self.about != nil) {
        [dictionary setObject:self.about forKey:kWSKeyAboutMe];
    }
    if (self.email != nil && self.email.length > 0) {
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
    [encoder encodeObject:self.uuid forKey:kKeyUuid];
    [encoder encodeObject:self.type forKey:kKeyType];
    [encoder encodeObject:self.email forKey:kKeyEmail];
    [encoder encodeObject:self.avatarURL forKey:kKeyAvatarURL];
    [encoder encodeObject:self.firstName forKey:kWSKeyFirstname];
    [encoder encodeObject:self.lastName forKey:kWSKeyLastname];
    [encoder encodeObject:self.about forKey:kWSKeyAboutMe];
    [encoder encodeObject:self.displayName forKey:kKeyDisplayName];
    [encoder encodeObject:self.phone forKey:kKeyUserPhone];
    [encoder encodeObject:self.token forKey:kKeyToken];
    [encoder encodeObject:self.tourCount forKey:kKeyTourCount];
    [encoder encodeObject:self.entourageCount forKey:kKeyEntourageCount];
    [encoder encodeObject:self.encounterCount forKey:kKeyEncounterCount];
    [encoder encodeObject:self.organization forKey:kKeyOrganization];
    [encoder encodeObject:self.partner forKey:kKeyPartner];
    [encoder encodeObject:self.conversation forKey:kKeyConversation];
    [encoder encodeObject:self.roles forKey:kKeyRoles];
    [encoder encodeBool:self.anonymous forKey:kKeyAnonymous];
    [encoder encodeObject:self.memberships forKey:kMemberships];
    [encoder encodeObject:self.address forKey:kAddress];
    [encoder encodeObject:self.firebaseProperties forKey:kFirebaseProperties];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        self.sid = [decoder decodeObjectForKey:kKeySid];
        self.uuid = [decoder decodeObjectForKey:kKeyUuid];
        self.type = [decoder decodeObjectForKey:kKeyType];
        self.email = [decoder decodeObjectForKey:kKeyEmail];
        self.avatarURL = [decoder decodeObjectForKey:kKeyAvatarURL];
        self.firstName = [decoder decodeObjectForKey:kWSKeyFirstname];
        self.lastName = [decoder decodeObjectForKey:kWSKeyLastname];
        self.about = [decoder decodeObjectForKey:kWSKeyAboutMe];
        self.displayName = [decoder decodeObjectForKey:kKeyDisplayName];
        self.phone = [decoder decodeObjectForKey:kKeyUserPhone];
        self.token = [decoder decodeObjectForKey:kKeyToken];
        self.tourCount = [decoder decodeObjectForKey:kKeyTourCount];
        self.entourageCount = [decoder decodeObjectForKey:kKeyEntourageCount];
        self.encounterCount = [decoder decodeObjectForKey:kKeyEncounterCount];
        self.organization = [decoder decodeObjectForKey:kKeyOrganization];
        self.partner = [decoder decodeObjectForKey:kKeyPartner];
        self.conversation = [decoder decodeObjectForKey:kKeyConversation];
        self.roles = [decoder decodeObjectForKey:kKeyRoles];
        self.anonymous = [decoder decodeBoolForKey:kKeyAnonymous];
        self.memberships = [decoder decodeObjectForKey:kMemberships];
        self.address = [decoder decodeObjectForKey:kAddress];
        self.firebaseProperties = [self sanitizeFirebaseProperties:[decoder decodeObjectForKey:kFirebaseProperties]];
    }
    return self;
}

#pragma mark - Helper functions

- (BOOL)hasActionZoneDefined {
    return self.address != nil;
}

- (BOOL)isRegisteredForPushNotifications {
    UIUserNotificationType type = [UIApplication sharedApplication].currentUserNotificationSettings.types;
    
    if (type != UIUserNotificationTypeNone) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isPro
{
    return [USER_TYPE_PRO isEqualToString:self.type];
}

- (BOOL)isCoordinator {
    if ([self.roles containsObject:kVisitorUserTag] ||
        [self.roles containsObject:kCoordinatorUserTag]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)hasSignedEthicsChart {
    return [self.roles containsObject:kEthicsCharterSignedTag];
}

- (BOOL)isAnonymous
{
    return self.anonymous;
}

- (NSString*)roleTag {
    if (self.roles) {
        NSString *key = self.roles.firstObject;
        if (key && ![key isEqualToString:kEthicsCharterSignedTag]) {
            return OTLocalizedString(key);
        }
    }
    return nil;
}

- (NSArray <OTUserMembershipListItem*>*)privateCircles {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", GROUP_TYPE_PRIVATE_CIRCLE];
    OTUserMembership *group = [self.memberships filteredArrayUsingPredicate:predicate].firstObject;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    return group ? [group.list sortedArrayUsingDescriptors:@[sortDescriptor]] : @[];
}

- (NSArray <OTUserMembershipListItem*>*)outings {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", GROUP_TYPE_OUTING];
    OTUserMembership *group = [self.memberships filteredArrayUsingPredicate:predicate].firstObject;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    return group ? [group.list sortedArrayUsingDescriptors:@[sortDescriptor]] : @[];
}

- (NSArray <OTUserMembershipListItem*>*)neighborhoods {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = %@", GROUP_TYPE_NEIGHBORHOOD];
    OTUserMembership *group = [self.memberships filteredArrayUsingPredicate:predicate].firstObject;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    return group ? [group.list sortedArrayUsingDescriptors:@[sortDescriptor]] : @[];
}

- (NSString *)formattedActionZoneAddress {
    if ([self hasActionZoneDefined]) {
        NSString *descText = [NSString stringWithFormat:@"Vous recevez les notifications pour les actions autour de : %@", self.address.displayAddress];
        return descText;
    }
    
    return OTLocalizedString(@"defineActionZoneDescription");
}

- (NSString *)uuid {
    if (_uuid != nil) {
        return _uuid;
    }

    // fallback to legacy id
    return self.sid.stringValue;
}

- (NSDictionary<NSString *, NSString *> *)sanitizeFirebaseProperties:(NSDictionary *)input {
    if (![input isKindOfClass:NSDictionary.class]) return @{};
    
    NSMutableDictionary<NSString *, NSString *> *output = [NSMutableDictionary new];
    
    for (NSString *key in input) {
        if (![key isKindOfClass:NSString.class]) continue;
        NSString *value = input[key];
        if (![value isKindOfClass:NSString.class] && ![key isKindOfClass:NSNull.class]) continue;
        output[key] = value;
    }
    
    return [NSDictionary dictionaryWithDictionary:output];
}

- (void)setFirebaseProperties:(NSDictionary<NSString *,NSString *> *)firebaseProperties {
    _firebaseProperties = [self sanitizeFirebaseProperties:firebaseProperties];
}

@end
