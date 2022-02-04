//
//  OTCategoryFromJsonService.h
//  entourage
//
//  Created by veronica.gliga on 24/09/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTCategoryFromJsonService : NSObject

+ (NSMutableArray *)getData;
+ (OTCategory*)categoryWithType:(NSString*)type subcategory:(NSString*)subCat;

+ (OTCategory*)sampleEntourageEventCategory;

@end
