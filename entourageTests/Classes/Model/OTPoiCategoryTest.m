//
//  OTPoiCategoryTest.m
//  entourage
//
//  Created by Louis Davin on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OTPoiCategory.h"
#import "OTTestHelper.h"

@interface OTPoiCategoryTest : XCTestCase

@end

@implementation OTPoiCategoryTest

- (void)test_PoiCategoryWithJSONDictionnary_withNilParameter
{
    // Given
    NSDictionary *nilDictionary = nil;
    
    // When
    OTPoiCategory *poiCategory = [OTPoiCategory poiWithJSONDictionnary:nilDictionary];
    
    // Then
    XCTAssertNil(poiCategory, @"");
}

- (void)test_PoiCategoryWithJSONDictionnary_withWrongParameterType
{
    // Given
    id array = [[NSArray alloc] init];
    
    // When
    OTPoiCategory *poiCategory = [OTPoiCategory poiWithJSONDictionnary:array];
    
    // Then
    XCTAssertNil(poiCategory, @"");
}

- (void)test_PoiCategoryWithJSONDictionnary_withCorrectInput
{
    // Given
    NSDictionary *dictionary = [OTTestHelper parseJSONFromFileNamed:@"poi_category_mock"];
    
    // When
    OTPoiCategory *poiCategory = [OTPoiCategory poiWithJSONDictionnary:dictionary];
    
    // Then
    XCTAssertNotNil(poiCategory, @"");
    XCTAssertEqualObjects(@1, poiCategory.sid, @"");
    XCTAssertEqualObjects(@"Pharmacie", poiCategory.name, @"");
}

@end
