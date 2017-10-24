//
//  OTCategoryViewController.h
//  entourage
//
//  Created by veronica.gliga on 21/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTCategory.h"

@protocol CategorySelectionDelegate <NSObject>

- (void)didSelectCategory:(OTCategory *)category;

@end

@interface OTCategoryViewController : UIViewController

@property (nonatomic, strong) OTCategory *selectedCategory;
@property (nonatomic, weak) id<CategorySelectionDelegate> categorySelectionDelegate;

@end
