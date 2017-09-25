//
//  OTCategory.h
//  entourage
//
//  Created by veronica.gliga on 24/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTCategory : NSObject

@property (nonatomic, strong) NSString *entourage_type;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *title_example;
@property (nonatomic, strong) NSString *description_example;
@property (nonatomic) BOOL isSelected;

@end
