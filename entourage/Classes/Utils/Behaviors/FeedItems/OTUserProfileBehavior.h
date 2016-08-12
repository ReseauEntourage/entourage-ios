//
//  OTUserProfileBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"

@interface OTUserProfileBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (void)showProfile:(NSNumber *)userId;
- (BOOL)prepareSegueForUserProfile:(UIStoryboardSegue *)segue;

@end
