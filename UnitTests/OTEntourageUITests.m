//
//  OTEntourageUITests.m
//  UnitTests
//
//  Created by Grégoire Clermont on 24/03/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OTEntourageUI.h"

@interface OTEntourageUITests : XCTestCase

@end

@implementation OTEntourageUITests

- (NSDate *)daysAgo:(double)days {
    return [NSDate dateWithTimeIntervalSinceNow:(-1 * days * 24 * 60 * 60)];
}

- (void)testCreatedToday {
    OTEntourage *entourage = [OTEntourage new];
    entourage.creationDate = [self daysAgo:0];

    OTEntourageUI *ui = [[OTEntourageUI alloc] initWithEntourage:entourage];
    XCTAssertEqualObjects([ui formattedTimestamps], @"Créé aujourd'hui");
}

- (void)testCreatedUpdated {
    OTEntourage *entourage = [OTEntourage new];
    entourage.creationDate = [self daysAgo:1];
    entourage.updatedDate  = [self daysAgo:0];

    OTEntourageUI *ui = [[OTEntourageUI alloc] initWithEntourage:entourage];
    XCTAssertEqualObjects([ui formattedTimestamps], @"Créé hier - actif aujourd'hui");
}

- (void)testFormatToday {
    NSDate *date = [self daysAgo:0];
    OTEntourageUI *ui = [OTEntourageUI alloc];
    XCTAssertEqualObjects([ui formattedDaysIntervalFromToday:date], @"aujourd'hui");
}

- (void)testFormatYesterday {
    NSDate *date = [self daysAgo:1];
    OTEntourageUI *ui = [OTEntourageUI alloc];
    XCTAssertEqualObjects([ui formattedDaysIntervalFromToday:date], @"hier");
}

- (void)testFormatDaysAgo {
    NSDate *date = [self daysAgo:2];
    OTEntourageUI *ui = [OTEntourageUI alloc];
    XCTAssertEqualObjects([ui formattedDaysIntervalFromToday:date], @"il y a 2 jours");
}

- (void)testFormatThisMonth {
    NSDate *date = [self daysAgo:15];
    OTEntourageUI *ui = [OTEntourageUI alloc];
    XCTAssertEqualObjects([ui formattedDaysIntervalFromToday:date], @"ce mois-ci");
}

- (void)testFormatMonthsAgoRoundDown {
    NSDate *date = [self daysAgo:44];
    OTEntourageUI *ui = [OTEntourageUI alloc];
    XCTAssertEqualObjects([ui formattedDaysIntervalFromToday:date], @"il y a 1 mois");
}

- (void)testFormatMonthsAgoRoundUp {
    NSDate *date = [self daysAgo:45];
    OTEntourageUI *ui = [OTEntourageUI alloc];
    XCTAssertEqualObjects([ui formattedDaysIntervalFromToday:date], @"il y a 2 mois");
}

@end
