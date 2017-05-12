//
//  OTToggleVisibleWithConstraintsBehavior.h
//  entourage
//
//  Created by sergiu.buceac on 08/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"

@interface OTToggleVisibleWithConstraintsBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIView *toggledView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *viewVisibleConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *viewInvisibleConstraint;

- (void)toggle:(BOOL)visible;

@end
