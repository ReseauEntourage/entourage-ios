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
    XCTAssertEqualObjects(@"MGEN", poi.name, @"");
    XCTAssertEqual(48.842416499999999, poi.latitude, @"");
    XCTAssertEqual(2.3101579999999999, poi.longitude, @"");
}

@end
