//
//  OTEditEntourageTableSource.h
//  entourage
//
//  Created by sergiu.buceac on 17/05/2017.
//  Copyright © 2017 Entourage. All rights reserved.
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
- (void)updateLocationAddress:(NSString*)streetAddress
                    placeName:(NSString*)placeName
                      placeId:(NSString*)placeId
               displayAddress:(NSString*)displayAddress;
- (void)updateTexts;
- (void)updateEventStartDate:(NSDate*)date;
- (void)updateEventEndDate:(NSDate*)date;
-(void)editEntourageActionPrivacy;
@end
