//
//  OTCategoryType.h
//  entourage
//
//  Created by veronica.gliga on 24/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTCategory.h"

@interface OTCategoryType : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, strong) NSMutableArray *categories;

@end
