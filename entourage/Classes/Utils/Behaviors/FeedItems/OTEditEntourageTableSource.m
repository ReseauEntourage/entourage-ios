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
    EditEntourageItemTypeLocation = 0,
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
    self.entourage.desc = entourage.desc;
    self.entourage.location = entourage.location;
    self.entourage.type = entourage.type;
    self.entourage.uid = entourage.uid;
    self.entourage.status = entourage.status;
    [self updateLocationTitle];
    self.tblEditEntourage.dataSource = self;
    self.tblEditEntourage.delegate = self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = indexPath.section > 0 ? @"EntourageCell" : @"EntourageImageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    switch (indexPath.section) {
        case 0:
            [((OTEntourageEditItemImageCell*)cell) configureWith:OTLocalizedString(@"myLocation") andText:self.locationText andImageName:@"location"];
            break;
        case 1:
            [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"title") andText:self.entourage.title];
            break;
        case 2:
            [((OTEntourageEditItemCell*)cell) configureWith:OTLocalizedString(@"descriptionTitle") andText:self.entourage.desc];
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
            [self.editEntourageNavigation editLocation:self.entourage];
            break;
        case 1:
            [self.editEntourageNavigation editTitle:self.entourage];
            break;
        case 2:
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
        [self.tblEditEntourage reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

@end
