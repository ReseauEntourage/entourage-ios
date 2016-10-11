//
//  OTEditEntourageBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/31/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTEntourage.h"

@interface OTEditEntourageBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (void)doEdit:(OTEntourage *)entourage;
- (BOOL)prepareSegue:(UIStoryboardSegue *)segue;


@end
