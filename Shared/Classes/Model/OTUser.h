//
//  OTUser.h
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTOrganization.h"
#import "OTAssociation.h"
#import "OTUserMembership.h"
#import "OTConversation.h"
#import "OTAddress.h"

extern NSString *const kKeyToken;
extern NSString *const kCoordinatorUserTag;
extern NSString *const kNotValidatedUserTag;
extern NSString *const kVisitorUserTag;
extern NSString *const kVisitedUserTag;

#define USER_TYPE_PRO       @"pro"
#define USER_TYPE_PUBLIC    @"public"

@interface OTUser : NSObject

@property (strong, nonatomic) NSNumber *sid;
@property (nonatomic, readonly) NSString *uuid;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *avatarURL;
@property (strong, nonatomic) NSString *avatarKey;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSNumber *tourCount;
@property (strong, nonatomic) NSNumber *entourageCount;
@property (strong, nonatomic) NSNumber *encounterCount;
@property (strong, nonatomic) NSString *about;
@property (strong, nonatomic) OTOrganization *organization;
@property (strong, nonatomic) OTAssociation *partner;
@property (strong, nonatomic) OTConversation *conversation;
@property (strong, nonatomic) OTAddress *addressPrimary;
@property (strong, nonatomic) OTAddress *addressSecondary;
@property (strong, nonatomic) NSArray *roles;
@property (nonatomic, readonly) NSArray *memberships;
@property (strong, nonatomic) NSDictionary<NSString *, NSString *> *firebaseProperties;
@property (strong, nonatomic,nullable) NSString *goal;
@property (nonatomic,strong) NSArray * _Nullable interests;
@property (nonatomic, strong) NSNumber *unreadCount;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryForWebservice;

/*
 * Returns true if it's a pro user
 */
- (BOOL)isPro;

- (BOOL)hasActionZoneDefined;

- (BOOL)isCoordinator;

- (BOOL)hasSignedEthicsChart;

- (BOOL)isAnonymous;

-(BOOL) isUserTypeAlone;
-(BOOL) isUserTypeNeighbour;
/*
 * Returns the name of the role to be displayed under the user's fullname
 */
- (NSString*)roleTag;
- (NSString*)uuid;

- (NSArray <OTUserMembershipListItem*>*)privateCircles;
- (NSArray <OTUserMembershipListItem*>*)neighborhoods;
- (NSArray <OTUserMembershipListItem*>*)outings;

- (NSString *)formattedActionZoneAddress;

- (NSString *_Nonnull)getInterestsFormated;

@property (strong, nonatomic) NSNumber * _Nonnull actionsCount;
@property (strong, nonatomic) NSNumber * _Nonnull eventsCount;
@property (nonatomic) BOOL isGoodWavesValidated;
@property (nonatomic) BOOL isEngaged;
@end
