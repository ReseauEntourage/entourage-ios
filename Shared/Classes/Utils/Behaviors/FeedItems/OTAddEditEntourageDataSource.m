//
//  OTAddEditEntourageDataSource.m
//  entourage
//
//  Created by Smart Care on 12/07/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTAddEditEntourageDataSource.h"
#import "OTEntourageEditItemCell.h"
#import "OTEntourageEditItemImageCell.h"
#import "OTConsts.h"
#import "NSDate+OTFormatter.h"
#import "entourage-Swift.h"
#import "OTEntouragePrivacyActionCell.h"

@interface OTAddEditEntourageDataSource ()
@end

@implementation OTAddEditEntourageDataSource

+ (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
                               entourage:(OTEntourage*)entourage {
    if ([entourage isOuting] && [OTAppConfiguration shouldShowEntouragePrivacyDisclaimerOnCreation:entourage]) {
        return 6;//5;
    }
    
    return 5;//4;
}

+ (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

+ (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                     entourage:(OTEntourage*)entourage
                  locationText:(NSString*)locationText
                      delegate:(id<OTAddEditEntourageDelegate>)delegate {
    
    if ([entourage isOuting]) {
        NSString *identifier = @"EntourageCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        switch (indexPath.section) {
            case 0:
                [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"addEventTitle")
                                                andText:entourage.title];
                break;
            case 1:
                [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"descriptionTitle")
                                                andText:entourage.desc];
                break;
            case 2: {
                NSString *address = entourage.streetAddress ?: entourage.displayAddress;
                [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"addEventAddress")
                                                        andText:address];
            }
                break;
            case 3: {
                NSString *startDateInfo = @"";
                if (entourage.startsAt) {
                    startDateInfo = [NSString stringWithFormat:@"%@%@%@",
                                     [entourage.startsAt asStringWithFormat:@"EEEE dd MMMM yyyy"],
                                     OTLocalizedString(@"at_hour"),
                                     entourage.startsAt.toTimeString];
                    
                }
                [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"addEventStartDate")
                                                        andText:startDateInfo];
            }
                break;
            case 4: {
                NSString *endDateInfo = @"";
                if (entourage.endsAt) {
                    endDateInfo = [NSString stringWithFormat:@"%@%@%@",
                                     [entourage.startsAt asStringWithFormat:@"EEEE dd MMMM yyyy"],
                                     OTLocalizedString(@"at_hour"),
                                     entourage.endsAt.toTimeString];
                    
                }
                [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"addEventEndDate")
                                                        andText:endDateInfo];
            }
                break;
            case 5:
                cell = [tableView dequeueReusableCellWithIdentifier:@"EntouragePrivacyCell"];
                [((OTEntourageEditItemCell*)cell) configureWithSwitchPublicState:entourage.isPublic.boolValue entourage:entourage];
                [((OTEntourageEditItemCell*)cell).privacySwitch
                 addTarget:delegate
                 action:@selector(editEntourageEventConfidentiality:) forControlEvents:UIControlEventValueChanged];
                break;
            default:
                break;
        }
        
        return cell;
    }
    
    NSString *identifier = indexPath.section != 1  ? @"EntourageCell" : @"EntourageImageCell";
    if (indexPath.section == 4) {
        identifier = @"EntouragePrivacyActionCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    switch (indexPath.section) {
        case 0:
            [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"category")
                                                    andText:entourage.categoryObject.title];
            break;
        case 1:
            [((OTEntourageEditItemImageCell*)cell) configureWith:OTLocalizedString(@"action_title_pres_de")
                                                         andText:locationText
                                                    andImageName:@"location"];
            break;
        case 2:
            [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"title")
                                                    andText:entourage.title];
            break;
        case 3:
            [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"descriptionTitle")
                                                    andText:entourage.desc];
            break;
        case 4:
            [(OTEntouragePrivacyActionCell*) cell setActionDelegate:delegate isPublic:entourage.isPublic.boolValue];
        default:
            break;
    }
    
    return cell;
}

+ (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
     withDelegate:(id<OTAddEditEntourageDelegate>)delegate
        entourage:(OTEntourage*)entourage {
    
    if ([entourage isOuting]) {
        switch (indexPath.section) {
            case 0:
                [delegate editEntourageTitle];
                break;
            case 1:
                [delegate editEntourageDescription];
                break;
            case 2:
                [delegate editEntourageAddress];
                break;
            case 3:
                [delegate editEntourageDate_isStart:YES];
                break;
            case 4:
                if (entourage.startsAt != nil) {
                    [delegate editEntourageDate_isStart:NO];
                }
                break;
            default:
                break;
        }
        
        return;
    }
    
    switch (indexPath.section) {
        case 0:
            [delegate editEntourageCategory];
            break;
        case 1:
            [delegate editEntourageLocation];
            break;
        case 2:
            [delegate editEntourageTitle];
            break;
        case 3:
            [delegate editEntourageDescription];
            break;
        default:
            break;
    }
}

+ (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 16.0f;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 4) {
        return UITableViewAutomaticDimension;
    }
    
    return 50.0f;
}

@end
