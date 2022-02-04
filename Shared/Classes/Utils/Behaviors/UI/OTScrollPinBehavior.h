//
//  OTScrollPinBehavior.h
//  entourage
//
//  Created by sergiu buceac on 9/5/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"

@interface OTScrollPinBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollHeightConstraint;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *pinnedViews;

@end
