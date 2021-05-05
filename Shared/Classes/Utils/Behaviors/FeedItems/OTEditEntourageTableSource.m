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
#import "OTAddEditEntourageDataSource.h"
#import "entourage-Swift.h"

#define TIME_ADDED_TO_END_DATE_EVENT 60 * 60 * 3
@interface OTEditEntourageTableSource () <UITableViewDataSource, UITableViewDelegate, OTAddEditEntourageDelegate>

@property (nonatomic, strong, readwrite) OTEntourage *entourage;
@property (nonatomic, strong) NSString *locationText;

@end

@implementation OTEditEntourageTableSource

- (void)configureWith:(OTEntourage *)entourage {
    
    self.tblEditEntourage.dataSource = self;
    self.tblEditEntourage.delegate = self;
    
    self.entourage = entourage ? entourage : [OTEntourage new];
    self.entourage.title = entourage.title;
    self.entourage.desc = entourage.desc == nil ? @"" : entourage.desc;
    self.entourage.location = entourage.location;
    self.entourage.entourage_type = entourage.categoryObject.entourage_type;
    self.entourage.uid = entourage.uid;
    self.entourage.status = entourage.status;
    self.entourage.category = entourage.category;
    self.entourage.categoryObject = entourage.categoryObject;
    self.entourage.streetAddress = entourage.streetAddress;
    self.entourage.startsAt = entourage.startsAt;
    self.entourage.endsAt = entourage.endsAt;
    self.entourage.displayAddress = entourage.displayAddress;
    self.entourage.googlePlaceId = entourage.googlePlaceId;
    self.entourage.placeName = entourage.placeName;
    
    if ([entourage isOuting]) {
        [self updateLocationAddress:entourage.streetAddress
                          placeName:entourage.placeName
                            placeId:entourage.googlePlaceId
                     displayAddress:entourage.displayAddress];
    } else {
        [self updateLocationTitle];
    }
    
    [self.tblEditEntourage reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [OTAddEditEntourageDataSource
            numberOfSectionsInTableView:tableView entourage:self.entourage];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [OTAddEditEntourageDataSource tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [OTAddEditEntourageDataSource tableView:tableView
                             cellForRowAtIndexPath:indexPath
                                         entourage:self.entourage
                                      locationText:self.locationText
                                          delegate:self isHomeNeo:self.isHomeNeo];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [OTAddEditEntourageDataSource tableView:tableView
                    didSelectRowAtIndexPath:indexPath
                               withDelegate:self entourage:self.entourage];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [OTAddEditEntourageDataSource tableView:tableView heightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [OTAddEditEntourageDataSource tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark -  OTAddEditEntourageDelegate -

- (void)editEntourageCategory
{
    [self.editEntourageNavigation editCategory:self.entourage];
}

- (void)editEntourageLocation
{
    [self.editEntourageNavigation editLocation:self.entourage];
}

- (void)editEntourageTitle
{
    [self.editEntourageNavigation editTitle:self.entourage];
}

- (void)editEntourageDescription
{
    [self.editEntourageNavigation editDescription:self.entourage];
}

- (void)editEntourageAddress
{
    [self.editEntourageNavigation editAddress:self.entourage];
}

- (void)editEntourageDate_isStart:(BOOL)isStartDate
{
    [self.editEntourageNavigation editDate:self.entourage isStart:isStartDate];
}

- (void)editEntourageEventConfidentiality:(UISwitch*)sender {
    self.entourage.isPublic = @(sender.on);
    [self.editEntourageNavigation editEventConfidentiality:self.entourage];
    [self.tblEditEntourage reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [OTAddEditEntourageDataSource numberOfSectionsInTableView:self.tblEditEntourage entourage:self.entourage])] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateTexts {
    [self.tblEditEntourage reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [OTAddEditEntourageDataSource numberOfSectionsInTableView:self.tblEditEntourage entourage:self.entourage])] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) editEntourageActionChangePrivacyPublic:(BOOL)isPublic {
    self.entourage.isPublic = [NSNumber numberWithBool:isPublic];
}

#pragma mark - geolocation

- (void)updateLocationTitle {
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:self.entourage.location
                   completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                       if (error)
                           NSLog(@"error: %@", error.description);
                       CLPlacemark *placemark = placemarks.firstObject;
                       if (placemark.thoroughfare !=  nil)
                           self.locationText = placemark.thoroughfare;
                       else
                           self.locationText = placemark.locality;
                       [self updateTexts];
                   }];
}

- (void)updateLocationAddress:(NSString*)streetAddress
                    placeName:(NSString*)placeName
                      placeId:(NSString*)placeId
               displayAddress:(NSString*)displayAddress {
    self.entourage.streetAddress = streetAddress;
    self.entourage.placeName = placeName;
    self.entourage.googlePlaceId = placeId;
    
    self.locationText = self.entourage.streetAddress ?: self.entourage.displayAddress;
    [self updateTexts];
}

- (void)updateEventStartDate:(NSDate*)date {
    self.entourage.startsAt = date;
    if (self.entourage.endsAt == nil) {
        self.entourage.endsAt = [self.entourage.startsAt dateByAddingTimeInterval:TIME_ADDED_TO_END_DATE_EVENT];
    }
    else {
        if ([[self.entourage.startsAt earlierDate:self.entourage.endsAt] isEqualToDate:self.entourage.endsAt]) {
            self.entourage.endsAt = [self.entourage.startsAt dateByAddingTimeInterval:TIME_ADDED_TO_END_DATE_EVENT];
        }
    }
    [self updateTexts];
}

- (void)updateEventEndDate:(NSDate*)date {
    self.entourage.endsAt = date;
    [self updateTexts];
}

@end
