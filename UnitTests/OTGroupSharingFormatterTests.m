//
//  OTGroupSharingFormatterTests.m
//  UnitTests
//
//  Created by Grégoire Clermont on 06/02/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OTGroupSharingFormatterTests.m"
#import "OTGroupSharingFormatter.h"
#import "OTEntourage.h"
#import "NSUserDefaults+OT.h"
#import "OTCrashlyticsHelper.h"
#import "entourage-Swift.h"

@interface OTGroupSharingFormatterTests : XCTestCase

@property OTUser *groupAuthor;
@property OTUser *otherUser;
@property OTEntourage *action;
@property OTEntourage *event;
@property OTEntourage *neighborhood;

@end

@implementation OTGroupSharingFormatterTests

- (void)setUp {
    self.groupAuthor = [[OTUser new] initWithDictionary:@{
        @"id": @1234
    }];
    self.otherUser = [[OTUser new] initWithDictionary:@{
        @"id": @1235
    }];
    self.action = [[OTEntourage new] initWithDictionary:@{
        @"group_type": @"action",
        @"title": @"TITRE",
        @"share_url": @"SHARE_URL",
        @"author": @{
                @"id": self.groupAuthor.sid
        }
    }];
    self.event = [[OTEntourage new] initWithDictionary:@{
        @"group_type": @"outing",
        @"title": @"TITRE",
        @"share_url": @"SHARE_URL",
        @"metadata": @{
                @"display_address": @"ADRESSE",
                @"starts_at": @"2020-04-15T10:00:00.000+02:00"
        }
    }];
    self.neighborhood = [[OTEntourage new] initWithDictionary:@{
        @"group_type": @"neighborhood",
        @"title": @"TITRE",
        @"share_url": @"SHARE_URL"
    }];
}

- (void)tearDown {
    [OTAppConfiguration sharedInstance].environmentConfiguration
      .applicationType = ApplicationTypeEntourage;
}

- (void)testActionAuthor {
    [NSUserDefaults standardUserDefaults].currentUser = self.groupAuthor;
    NSString *message = [OTGroupSharingFormatter groupShareText:self.action];

    NSString *expected =
        @"Hello ! J'ai créé une initiative solidaire sur Entourage, le réseau qui "
         "tisse des liens entre voisins avec et sans domicile : \"TITRE\". "
         "J’ai pensé que ça t'intéresserait. Clique ici : SHARE_URL.\n"
         "\n"
         "Merci beaucoup pour ta solidarité !";
    XCTAssertEqualObjects(message, expected);
}

- (void)testActionMember {
    [NSUserDefaults standardUserDefaults].currentUser = self.otherUser;
    self.action.joinStatus = JOIN_ACCEPTED;

    NSString *message = [OTGroupSharingFormatter groupShareText:self.action];
    NSString *expected =
        @"Hello ! J'ai rejoint une initiative solidaire sur Entourage, le réseau qui "
         "tisse des liens entre voisins avec et sans domicile : \"TITRE\". "
         "J’ai pensé que ça t'intéresserait. Clique ici : SHARE_URL.\n"
         "\n"
         "Merci beaucoup pour ta solidarité !";
    XCTAssertEqualObjects(message, expected);
}

- (void)testActionOther {
    [NSUserDefaults standardUserDefaults].currentUser = self.otherUser;
    self.action.joinStatus = JOIN_NOT_REQUESTED;

    NSString *message = [OTGroupSharingFormatter groupShareText:self.action];
    NSString *expected =
        @"Hello ! J'ai vu une initiative solidaire sur Entourage, le réseau qui "
         "tisse des liens entre voisins avec et sans domicile : \"TITRE\". "
         "J’ai pensé que ça t'intéresserait. Clique ici : SHARE_URL.\n"
         "\n"
         "Merci beaucoup pour ta solidarité !";
    XCTAssertEqualObjects(message, expected);
}

- (void)testEvent {
    NSString *message = [OTGroupSharingFormatter groupShareText:self.event];

    NSString *expected =
        @"Hello ! Je t'invite à : \"TITRE\", le mercredi 15 avril à 10h00, ADRESSE !\n"
         "\n"
         "Si ça te dit d'y participer, rejoins-moi ici sur Entourage, le réseau qui crée "
         "des liens entre voisins avec et sans domicile : SHARE_URL";
    XCTAssertEqualObjects(message, expected);
}

@end
