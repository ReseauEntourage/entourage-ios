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
#import "OTLocalisationService.h"

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
NSString *const kAddress2 = @"address_2";
NSString *const kFirebaseProperties = @"firebase_properties";

NSString *const kCoordinatorUserTag = @"coordinator";
NSString *const kNotValidatedUserTag = @"not_validated";
NSString *const kVisitorUserTag = @"visitor";
NSString *const kVisitedUserTag = @"visited";
NSString *const kEthicsCharterSignedTag = @"ethics_charter_signed";
NSString *const kGoal = @"goal";
NSString *const kInterests = @"interests";

NSString *const kKeyEventsCount = @"events_count";
NSString *const kKeyActionsCount = @"actions_count";
NSString *const kKeyGoodWavesParticipate = @"good_waves_participation";
NSString *const kKeyEngaged = @"engaged";

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
        
        _goal = [dictionary stringForKey:kGoal];
        
        _eventsCount = [[dictionary objectForKey:kKeyStats] numberForKey:kKeyEventsCount defaultValue:0];
        _actionsCount = [[dictionary objectForKey:kKeyStats] numberForKey:kKeyActionsCount defaultValue:0];
        _isGoodWavesValidated = [[dictionary objectForKey:kKeyStats] boolForKey:kKeyGoodWavesParticipate defaultValue:NO];
        _isEngaged = [dictionary boolForKey:kKeyEngaged defaultValue:NO];
        
        if ([[dictionary allKeys] containsObject:kKeyConversation]) {
            _conversation = [[OTConversation alloc] initWithDictionary:[dictionary objectForKey:kKeyConversation]];
        }
        
        if ([[dictionary allKeys] containsObject:kKeyRoles]) {
            _roles = [dictionary arrayWithObjectsOfClass:[NSString class] forKey:kKeyRoles];
        }
        
        if ([[dictionary allKeys] containsObject:kAddress]) {
            _addressPrimary = [[OTAddress alloc] initWithDictionary:[dictionary objectForKey:kAddress]];
        }
        
        if ([[dictionary allKeys] containsObject:kAddress2]) {
            _addressSecondary = [[OTAddress alloc] initWithDictionary:[dictionary objectForKey:kAddress2]];
        }
        
        NSArray *membershipArray = [dictionary objectForKey:kMemberships];
        NSMutableArray *userMemberships = [[NSMutableArray alloc] init];
        for (NSDictionary *membershipDict in membershipArray) {
            OTUserMembership *userMembership = [[OTUserMembership alloc] initWithDictionary:membershipDict];
            [userMemberships addObject:userMembership];
        }
        _memberships = userMemberships;
        
        _interests = [dictionary objectForKey:kInterests];
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
    
    if (self.goal != nil) {
        [dictionary setObject:self.goal forKey:kGoal];
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
    [encoder encodeObject:self.addressPrimary forKey:kAddress];
    [encoder encodeObject:self.firebaseProperties forKey:kFirebaseProperties];
    [encoder encodeObject:self.goal forKey:kGoal];
    [encoder encodeObject:self.addressSecondary forKey:kAddress2];
    [encoder encodeObject:self.interests forKey:kInterests];
    
    [encoder encodeObject:self.eventsCount forKey:kKeyEventsCount];
    [encoder encodeObject:self.actionsCount forKey:kKeyActionsCount];
    [encoder encodeObject:[NSNumber numberWithBool:self.isGoodWavesValidated] forKey:kKeyGoodWavesParticipate];
    [encoder encodeObject:[NSNumber numberWithBool:self.isEngaged] forKey:kKeyEngaged];
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
        self.addressPrimary = [decoder decodeObjectForKey:kAddress];
        self.firebaseProperties = [self sanitizeFirebaseProperties:[decoder decodeObjectForKey:kFirebaseProperties]];
        self.goal = [decoder decodeObjectForKey:kGoal];
        self.addressSecondary = [decoder decodeObjectForKey:kAddress2];
        self.interests = [decoder decodeObjectForKey:kInterests];
        
        self.eventsCount = [decoder decodeObjectForKey:kKeyEventsCount];
        self.actionsCount = [decoder decodeObjectForKey:kKeyActionsCount];
        self.isGoodWavesValidated = [[decoder decodeObjectForKey:kKeyGoodWavesParticipate] boolValue];
        self.isEngaged = [[decoder decodeObjectForKey:kKeyEngaged] boolValue];
    }
    return self;
}

#pragma mark - Helper functions

- (BOOL)hasActionZoneDefined {
    return self.addressPrimary != nil;
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
        NSString *descText = [NSString stringWithFormat:@"Vous recevez les notifications pour les actions autour de : %@", self.addressPrimary.displayAddress];
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

-(NSString *)getInterestsFormated {
    NSString * interests = @"";
    
    int i = 0;
    for (NSString *interest in self.interests) {
        if (i < self.interests.count - 1) {
            interests = [NSString stringWithFormat:@"%@ %@,",interests,[OTLocalisationService getLocalizedValueForKey:interest]];
        }
        else {
           interests = [NSString stringWithFormat:@"%@ %@",interests,[OTLocalisationService getLocalizedValueForKey:interest]];
        }
        i = i + 1;
    }
    
    return interests;
}

-(BOOL) isUserTypeAlone {
    BOOL isAlone = YES;
    
    if (![self.goal isEqualToString:@"ask_for_help"]) {
        isAlone = NO;
    }
    
    return isAlone;
}

-(BOOL) isUserTypeNeighbour {
    BOOL isNeighbour = NO;
    
    if ([self.goal isEqualToString:@"offer_help"]) {
        isNeighbour = YES;
    }
    
    return isNeighbour;
}



@end
