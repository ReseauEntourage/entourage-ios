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
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"categoryJson"
                                                     ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    NSData *error = nil;
    NSDictionary *categoryObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:0
                                                                     error:&error];
    NSArray *jsonArray = (NSArray *)categoryObject;
    
//    if(!error) {
//        OTCategoryType *categoryType = [[OTCategoryType alloc] init];
//        
//        for(NSDictionary *dictionary in jsonArray) {
//            
//            OTCategory *category = [[OTCategory alloc] init];
//            categoryType.type = [dictionary valueForKey:kWSKeyEntourageType];
//            category.category = [dictionary valueForKey:kWSKeyEntourageCategory];
//            category.title = [dictionary valueForKey: kWSKeyCategoryTitle];
//            category.title_example = [dictionary valueForKey:kWSKeyCategoryExampleTitle];
//            category.description_example = [dictionary valueForKey:kWSKeyCategoryExampleDescription];
//            
//            categoryType.categories = [[NSMutableArray alloc] init];
//            [categoryType.categories addObject:category];
//            [array addObject: categoryType];
//        }
//    }
    
    
    NSMutableArray *resultArray = [NSMutableArray new];
    NSArray *groups = [jsonArray valueForKeyPath:@"@distinctUnionOfObjects.entourage_type"];
    for (NSString *groupId in groups)
    {
        NSMutableDictionary *entry = [NSMutableDictionary new];
        [entry setObject:groupId forKey:@"entourage_type"];
        
        NSArray *groupNames = [jsonArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entourage_type = %@", groupId]];
        OTCategoryType *categoryType = [[OTCategoryType alloc] init];
        categoryType.categories = [[NSMutableArray alloc] init];
        for (int i = 0; i < groupNames.count; i++)
        {
            id object = [groupNames objectAtIndex:i];
            OTCategory *category = [[OTCategory alloc] init];
            categoryType.type = [object valueForKey:kWSKeyEntourageType];
            category.category = [object valueForKey:kWSKeyEntourageCategory];
            category.title = [object valueForKey: kWSKeyCategoryTitle];
            category.title_example = [object valueForKey:kWSKeyCategoryExampleTitle];
            category.description_example = [object valueForKey:kWSKeyCategoryExampleDescription];
            
            [categoryType.categories addObject:category];
            //NSString *name = [[groupNames objectAtIndex:i] objectForKey:@"name"];
            //[entry setObject:name forKey:[NSString stringWithFormat:@"name%d", i + 1]];
            
        }
        [resultArray addObject:categoryType];
    }
    
    return resultArray;
}

@end
