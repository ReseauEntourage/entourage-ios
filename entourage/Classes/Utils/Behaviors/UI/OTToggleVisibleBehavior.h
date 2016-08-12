//
//  OTToggleVisibleBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"

@interface OTToggleVisibleBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;
@property (nonatomic, weak) IBOutlet UIView *toggleView;

- (void)toggle:(BOOL)visible animated:(BOOL)animated;

@end
