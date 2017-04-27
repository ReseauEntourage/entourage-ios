//
//  OTSolidarityGuideCell.m
//  entourage
//
//  Created by veronica.gliga on 26/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSolidarityGuideCell.h"
#import "OTSolidarityGuideFilterItem.h"
#import "OTSolidarityGuideFilter.h"
#import "OTPoi.h"
#import "OTLocationManager.h"
#import "OTSummaryProviderBehavior.h"

NSString* const OTSolidarityGuideTableViewCellIdentifier = @"OTSolidarityGuideTableViewCellIdentifier";

@implementation OTSolidarityGuideCell

- (void)configureWith:(OTPoi *)poi {
    self.titleLabel.text = poi.name;
    self.typeLabel.text = [OTSolidarityGuideFilterItem categoryStringForKey:poi.categoryId.intValue];
    self.addressLabel.text = poi.address;
    self.distanceLabel.text = [self getDistance:poi];
}

#pragma mark - private methods

- (NSString *)getDistance:(OTPoi *)poi {
    double distance = [self calculateDistanceToPoi:poi];
    return [OTSummaryProviderBehavior toDistance:distance];
}

- (double)calculateDistanceToPoi:(OTPoi *)poi {
    CLLocation* poiLocation = [[CLLocation alloc] initWithLatitude:poi.latitude longitude:poi.longitude];
    CLLocation *currentLocation = [OTLocationManager sharedInstance].currentLocation;
    if(!currentLocation)
        return -1;
    return [currentLocation distanceFromLocation:poiLocation];
}

@end
