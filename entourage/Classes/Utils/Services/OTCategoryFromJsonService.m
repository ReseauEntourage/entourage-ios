//
//  OTCategoryFromJsonService.m
//  entourage
//
//  Created by veronica.gliga on 24/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTCategoryFromJsonService.h"
#import "OTCategoryType.h"
#import "OTCategory.h"
#import "OTAPIKeys.h"

@implementation OTCategoryFromJsonService

+ (NSMutableArray *)getData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"categoryJson"
                                                     ofType:@"json"];
    //NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSData *error = nil;
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *categoryObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:0
                                                                     error:&error];
    
    NSArray *jsonArray = (NSArray *)categoryObject;
    NSMutableArray *resultArray = [NSMutableArray new];
    NSArray *groups = [jsonArray valueForKeyPath:@"@distinctUnionOfObjects.entourage_type"];
    for (NSString *groupId in groups)
    {
        NSMutableDictionary *entry = [NSMutableDictionary new];
        [entry setObject:groupId forKey:@"entourage_type"];
        
        NSArray *groupNames = [jsonArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entourage_type = %@", groupId]];
        OTCategoryType *categoryType = [[OTCategoryType alloc] init];
        categoryType.isExpanded = YES;
        categoryType.categories = [[NSMutableArray alloc] init];
        for (int i = 0; i < groupNames.count; i++)
        {
            id object = [groupNames objectAtIndex:i];
            OTCategory *category = [[OTCategory alloc] init];
//            categoryType.type = [self decodeSpecialCharactersForObject:object andKey:kWSKeyEntourageType];
//            category.entourage_type = [self decodeSpecialCharactersForObject:object andKey:kWSKeyEntourageType];
//            category.category =[self decodeSpecialCharactersForObject:object andKey:kWSKeyEntourageCategory];
//            category.title = [self decodeSpecialCharactersForObject:object andKey:kWSKeyCategoryTitle];
//            category.title_example = [self decodeSpecialCharactersForObject:object andKey:kWSKeyCategoryExampleTitle];
//            category.description_example = [self decodeSpecialCharactersForObject:object andKey:kWSKeyCategoryExampleDescription];
            categoryType.type = [object valueForKey:kWSKeyEntourageType];
            category.entourage_type = [object valueForKey:kWSKeyEntourageType];
            category.category = [object valueForKey:kWSKeyEntourageCategory];
            category.title = [object valueForKey: kWSKeyCategoryTitle];
            category.title_example = [object valueForKey:kWSKeyCategoryExampleTitle];
            category.description_example = [object valueForKey:kWSKeyCategoryExampleDescription];
            [categoryType.categories addObject:category];
        }
        [resultArray addObject:categoryType];
    }
    return resultArray;
}

+ (NSString *)decodeSpecialCharactersForObject: (id)object andKey: (NSString *)key {
    NSString *objectValue = [object valueForKey:key];
    if (![objectValue isEqual:[NSNull null]])
        @try {
            return [NSString stringWithUTF8String:[objectValue cStringUsingEncoding:NSMacOSRomanStringEncoding]];
        }
    @catch (NSException *ex) {
        return [NSString stringWithCString:[objectValue cStringUsingEncoding:NSUTF8StringEncoding]
                                  encoding:NSUTF8StringEncoding];
    }
    return @"";
}

@end
