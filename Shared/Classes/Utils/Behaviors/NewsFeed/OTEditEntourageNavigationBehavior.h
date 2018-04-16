//
//  OTEditEntourageNavigationBehavior.h
//  entourage
//
//  Created by sergiu.buceac on 18/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTEntourage.h"
@class OTEditEntourageTableSource;

@interface OTEditEntourageNavigationBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;
@property (nonatomic, weak) IBOutlet OTEditEntourageTableSource *editEntourageSource;

- (BOOL)prepareSegue:(UIStoryboardSegue *)segue;

- (void)editLocation:(OTEntourage *)entourage;
- (void)editTitle:(OTEntourage *)entourage;
- (void)editDescription:(OTEntourage *)entourage;
- (void)editCategory:(OTEntourage *)entourage;

@end
