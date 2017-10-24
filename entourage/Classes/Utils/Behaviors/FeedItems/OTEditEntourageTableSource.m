//
//  OTEditEntourageTableSource.m
//  entourage
//
//  Created by sergiu.buceac on 17/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEditEntourageTableSource.h"
#import "OTEntourageEditItemCell.h"
#import "OTEntourageEditItemImageCell.h"
#import "OTConsts.h"

typedef enum {
    EditEntourageItemTypeCategory,
    EditEntourageItemTypeLocation = 1,
    EditEntourageItemTypetitle,
    EditEntourageItemTypeDescription
} EditEntourageItemType;

@interface OTEditEntourageTableSource () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readwrite) OTEntourage *entourage;
@property (nonatomic, strong) NSString *locationText;

@end

@implementation OTEditEntourageTableSource

- (void)configureWith:(OTEntourage *)entourage {
    self.entourage = [OTEntourage new];
    self.entourage.title = entourage.title;
    self.entourage.desc = entourage.desc == nil ? @"" : entourage.desc;
    self.entourage.location = entourage.location;
    self.entourage.entourage_type = entourage.categoryObject.entourage_type;
    self.entourage.uid = entourage.uid;
    self.entourage.status = entourage.status;
    self.entourage.category = entourage.category;
    self.entourage.categoryObject = entourage.categoryObject;
    [self updateLocationTitle];
    self.tblEditEntourage.dataSource = self;
    self.tblEditEntourage.delegate = self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = indexPath.section != 1  ? @"EntourageCell" : @"EntourageImageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    switch (indexPath.section) {
        case 0:
            [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"category")
                                                    andText:self.entourage.categoryObject.title];
            break;
        case 1:
            [((OTEntourageEditItemImageCell*)cell) configureWith:OTLocalizedString(@"myLocation")
                                                         andText:self.locationText
                                                    andImageName:@"location"];
            break;
        case 2:
            [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"title")
                                                    andText:self.entourage.title];
            break;
        case 3:
            [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"descriptionTitle")
                                                    andText:self.entourage.desc];
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            [self.editEntourageNavigation editCategory:self.entourage];
            break;
        case 1:
            [self.editEntourageNavigation editLocation:self.entourage];
            break;
        case 2:
            [self.editEntourageNavigation editTitle:self.entourage];
            break;
        case 3:
            [self.editEntourageNavigation editDescription:self.entourage];
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 16.0f;
}

#pragma mark - geolocation

- (void)updateLocationTitle {
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:self.entourage.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error)
            NSLog(@"error: %@", error.description);
        CLPlacemark *placemark = placemarks.firstObject;
        if (placemark.thoroughfare !=  nil)
            self.locationText = placemark.thoroughfare;
        else
            self.locationText = placemark.locality;
        [self.tblEditEntourage reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

- (void)updateTexts {
    [self.tblEditEntourage reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] withRowAnimation:UITableViewRowAnimationFade];
}

@end
