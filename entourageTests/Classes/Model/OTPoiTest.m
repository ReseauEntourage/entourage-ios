//
//  OTPoiTest.m
//  OTPoiTest
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OTPoi.h"
#import "OTTestHelper.h"

@interface OTPoiTest : XCTestCase

@end

@implementation OTPoiTest

- (void)test_PoiWithJSONDictionnary_withNilParameter
{
    // Given
    NSDictionary *nilDictionary = nil;

    // When
    OTPoi *poi = [OTPoi poiWithJSONDictionnary:nilDictionary];

    // Then
    XCTAssertNil(poi, @"");
}

- (void)test_PoiWithJSONDictionnary_withWrongParameterType
{
    // Given
    id array = [[NSArray alloc] init];

    // When
    OTPoi *poi = [OTPoi poiWithJSONDictionnary:array];

    // Then
    XCTAssertNil(poi, @"");
}

- (void)test_PoiWithJSONDictionnary_withCorrectInput
{
    // Given
    NSDictionary *dictionary = [OTTestHelper parseJSONFromFileNamed:@"poi_mock"];

    // When
    OTPoi *poi = [OTPoi poiWithJSONDictionnary:dictionary];

    // Then
    XCTAssertNotNil(poi, @"");
    XCTAssertEqualObjects(@2, poi.sid, @"");
    XCTAssertEqualObjects(@"Concorde", poi.name, @"");
    XCTAssertEqualObjects(@"jf dsmlfmdslk", poi.details, @"");
    XCTAssertEqual(2.321236, poi.longitude, @"");
    XCTAssertEqual(48.865633, poi.latitude, @"");
    XCTAssertEqualObjects(@"Place de la concorde", poi.address, @"");
    XCTAssertEqualObjects(@"0101010101", poi.phone, @"");
    XCTAssertEqualObjects(@"www.concorde.com", poi.website, @"");
    XCTAssertEqualObjects(@"plop@octo.com", poi.email, @"");
    XCTAssertEqualObjects(@"Tous publics", poi.audience, @"");
    XCTAssertEqualObjects(@1, poi.categoryId, @"");
}

@end
