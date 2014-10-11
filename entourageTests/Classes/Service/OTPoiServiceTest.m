//
//  OTPoiServiceTest.m
//  entourage
//
//  Created by Louis Davin on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OTPoiService.h"
#import "OTTestHelper.h"
#import "OTPoi.h"
#import "OTEncounter.h"
#import "OTPoiCategory.h"

@interface OTPoiService ()
- (NSMutableArray *)poisFromDictionary:(NSDictionary *)data;
- (NSMutableArray *)categoriesFromDictionary:(NSDictionary *)data;
- (NSMutableArray *)encountersFromDictionary:(NSDictionary *)data;
@end

@interface OTPoiServiceTest : XCTestCase
@end

@interface OTPoiServiceTest ()
@property(nonatomic, strong) OTPoiService *poiService;
@end

@implementation OTPoiServiceTest


- (void)setUp
{
    self.poiService = [OTPoiService new];
}

/**************************************************************************************************/
#pragma mark - poisFromDictionary

- (void)test_poisFromDictionary_withNilInput
{
    // Given
    NSDictionary *dictionary = nil;

    // When
    NSMutableArray *pois = [self.poiService poisFromDictionary:dictionary];

    // Then
    XCTAssertNotNil(pois, @"");
}

- (void)test_poisFromDictionary_withCorrectInput
{
    // Given
    NSDictionary *dictionary = [OTTestHelper parseJSONFromFileNamed:@"pois_categories_mock"];

    // When
    NSMutableArray *pois = [self.poiService poisFromDictionary:dictionary];

    // Then
    XCTAssertNotNil(pois, @"");
    XCTAssertEqual(2, pois.count, @"");

    OTPoi *firstPoi = pois.firstObject;
    OTPoi *lastPoi = pois.lastObject;
    XCTAssertEqualObjects(@"Concorde", firstPoi.name, @"");
    XCTAssertEqualObjects(@"Octo", lastPoi.name, @"");
}


/**************************************************************************************************/
#pragma mark - categoriesFromDictionary

- (void)test_categoriesFromDictionary_withNilInput
{
    // Given
    NSDictionary *dictionary = nil;

    // When
    NSMutableArray *pois = [self.poiService categoriesFromDictionary:dictionary];

    // Then
    XCTAssertNotNil(pois, @"");
}

- (void)test_categoriesFromDictionary_withCorrectInput
{
    // Given
    NSDictionary *dictionary = [OTTestHelper parseJSONFromFileNamed:@"pois_categories_mock"];

    // When
    NSMutableArray *pois = [self.poiService categoriesFromDictionary:dictionary];

    // Then
    XCTAssertNotNil(pois, @"");
    XCTAssertEqual(2, pois.count, @"");

    OTPoiCategory *firstCategory = pois.firstObject;
    OTPoiCategory *lastCategory = pois.lastObject;
    XCTAssertEqualObjects(@"Se nourrir", firstCategory.name, @"");
    XCTAssertEqualObjects(@"Se loger", lastCategory.name, @"");
}

/**************************************************************************************************/
#pragma mark - encountersFromDictionary

- (void)test_encountersFromDictionary_withNilInput
{
    // Given
    NSDictionary *dictionary = nil;
    
    // When
    NSMutableArray *pois = [self.poiService encountersFromDictionary:dictionary];
    
    // Then
    XCTAssertNotNil(pois, @"");
}

- (void)test_encountersFromDictionary_withCorrectInput
{
    // Given
    NSDictionary *dictionary = [OTTestHelper parseJSONFromFileNamed:@"pois_categories_mock"];
    
    // When
    NSMutableArray *encounters = [self.poiService encountersFromDictionary:dictionary];
    
    // Then
    XCTAssertNotNil(encounters, @"");
    XCTAssertEqual(1, encounters.count, @"");
    
    OTEncounter *firstEncounter = encounters.firstObject;
    XCTAssertEqualObjects(@1, firstEncounter.sid, @"");
    XCTAssertNotNil(firstEncounter.date, @"");
    XCTAssertEqualObjects(@2.320442, firstEncounter.longitude, @"");
    XCTAssertEqualObjects(@48.857464, firstEncounter.latitude, @"");
    XCTAssertEqualObjects(@1, firstEncounter.userId, @"");
    XCTAssertEqualObjects(@"Henry", firstEncounter.userName, @"");
    XCTAssertEqualObjects(@"Mario", firstEncounter.streetPersonName, @"");
    XCTAssertEqualObjects(@"Message de la rencontre", firstEncounter.message, @"");
    XCTAssertEqualObjects(@"http://futur.url/de/l-enregistrement.mp3", firstEncounter.voiceMessage, @"");
}

@end
