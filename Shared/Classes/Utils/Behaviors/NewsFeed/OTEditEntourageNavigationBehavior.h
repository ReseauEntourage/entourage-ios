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
@property(nonatomic) BOOL isFromHomeNeo;

- (BOOL)prepareSegue:(UIStoryboardSegue *)segue isAskForHelp:(BOOL) isAskForHelp;

- (void)editLocation:(OTEntourage *)entourage;
- (void)editTitle:(OTEntourage *)entourage;
- (void)editDescription:(OTEntourage *)entourage;
- (void)editCategory:(OTEntourage *)entourage;
- (void)editAddress:(OTEntourage *)entourage;
- (void)editDate:(OTEntourage *)entourage isStart:(BOOL)isStartDate;
- (void)editEventConfidentiality:(OTEntourage *)entourage;

@end
