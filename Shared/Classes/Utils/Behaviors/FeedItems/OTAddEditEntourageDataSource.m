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

@interface OTAddEditEntourageDataSource ()
@end

@implementation OTAddEditEntourageDataSource

+ (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
                               entourage:(OTEntourage*)entourage {
    if ([entourage isOuting]) {
        return 5;
    }
    return 4;
}

+ (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

+ (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                     entourage:(OTEntourage*)entourage
                  locationText:(NSString*)locationText {
    
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
            case 2:
                [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"addEventAddress")
                                                        andText:entourage.streetAddress];
                break;
            case 3: {
                NSString *startDateInfo = entourage.startsAt ?
                    [entourage.startsAt asStringWithFormat:@"EEEE dd MMMM yyyy"] : @"";
                [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"addEventDate")
                                                        andText:startDateInfo];
            }
                break;
            case 4:
                cell = [tableView dequeueReusableCellWithIdentifier:@"EntouragePrivacyCell"];
                [((OTEntourageEditItemCell*)cell) configureWithSwitchPublicState:YES];
                break;
            default:
                break;
        }
        
        return cell;
    }
    
    NSString *identifier = indexPath.section != 1  ? @"EntourageCell" : @"EntourageImageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    switch (indexPath.section) {
        case 0:
            [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"category")
                                                    andText:entourage.categoryObject.title];
            break;
        case 1:
            [((OTEntourageEditItemImageCell*)cell) configureWith:OTLocalizedString(@"myLocation")
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
                [delegate editEntourageDate];
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
        return 100.0f;
    }
    
    return 50.0f;
}

@end
