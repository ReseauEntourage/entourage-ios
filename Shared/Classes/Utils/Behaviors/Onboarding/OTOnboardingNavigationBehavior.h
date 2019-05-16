//
//  OTOnboardingNavigationBehavior.h
//  entourage
//
//  Created by sergiu buceac on 9/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"

@interface OTOnboardingNavigationBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController* owner;

- (void)nextFromEmail;
- (void)nextFromName;

@end
