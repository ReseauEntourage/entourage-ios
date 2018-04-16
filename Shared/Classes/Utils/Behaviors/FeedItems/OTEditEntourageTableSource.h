//
//  OTEditEntourageTableSource.h
//  entourage
//
//  Created by sergiu.buceac on 17/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTEntourage.h"
#import "OTEditEntourageNavigationBehavior.h"

@interface OTEditEntourageTableSource : OTBehavior

@property (nonatomic, weak) IBOutlet UITableView *tblEditEntourage;
@property (nonatomic, weak) IBOutlet OTEditEntourageNavigationBehavior *editEntourageNavigation;
@property (nonatomic, strong, readonly) OTEntourage *entourage;

- (void)configureWith:(OTEntourage *)entourage;
- (void)updateLocationTitle;
- (void)updateTexts;

@end
