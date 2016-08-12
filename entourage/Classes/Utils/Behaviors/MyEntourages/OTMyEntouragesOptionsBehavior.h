//
//  OTMyEntouragesOptionsBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTOptionsViewController.h"

@interface OTMyEntouragesOptionsBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (BOOL)prepareSegueForOptions:(UIStoryboardSegue *)segue;
- (void)configureWith:(id<OTOptionsDelegate>)optionsDelegate;

@end
