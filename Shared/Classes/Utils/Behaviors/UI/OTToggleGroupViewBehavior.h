//
//  OTToggleGroupViewBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"

@interface OTToggleGroupViewBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *marginConstraint;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *relatedViews;

- (void)toggle:(BOOL)visible;

@end
