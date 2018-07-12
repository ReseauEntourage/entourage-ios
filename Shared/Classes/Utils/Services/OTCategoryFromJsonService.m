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
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *categoryObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:0
                                                                     error:nil];
    
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
            categoryType.type = [object valueForKey:kWSKeyEntourageType];
            category.entourage_type = [object valueForKey:kWSKeyEntourageType];
            category.category = [object valueForKey:kWSKeyEntourageCategory];
            category.title = [object valueForKey:kWSKeyCategoryTitle];
            category.title_example = [object valueForKey:kWSKeyCategoryExampleTitle];
            category.description_example = [object valueForKey:kWSKeyCategoryExampleDescription];
            [categoryType.categories addObject:category];
        }
        [resultArray addObject:categoryType];
    }
    
    NSSortDescriptor *valueDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES];
    resultArray = (NSMutableArray *)[resultArray sortedArrayUsingDescriptors:@[valueDescriptor]];
    
    return resultArray;
}
    
+ (OTCategory*)categoryWithType:(NSString*)type subcategory:(NSString*)subCat {
    NSArray *data = [OTCategoryFromJsonService getData];
    for (OTCategoryType *categoryType in data) {
        for (OTCategory *category in categoryType.categories) {
            if ([category.entourage_type isEqualToString:type] &&
                [category.category isEqualToString:subCat]) {
                return category;
            }
        }
    }
    
    return nil;
}

@end
