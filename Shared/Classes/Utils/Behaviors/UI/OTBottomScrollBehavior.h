//
//  OTBottomScrollBehavior.h
//  entourage
//
//  Created by sergiu buceac on 2/16/17.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTBehavior.h"

@interface OTBottomScrollBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *table;

@end
