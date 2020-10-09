//
//  OTSolidarityGuideCell.m
//  entourage
//
//  Created by veronica.gliga on 26/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSolidarityGuideCell.h"
#import "OTLocationManager.h"
#import "OTSummaryProviderBehavior.h"
#import "entourage-Swift.h"

NSString* const OTSolidarityGuideTableViewCellIdentifier = @"OTSolidarityGuideTableViewCellIdentifier";

@interface OTSolidarityGuideCell ()

@property(nonatomic, strong) OTPoi *poiItem;

@end

@implementation OTSolidarityGuideCell

- (void)configureWith:(OTPoi *)poi {
    self.poiItem = poi;
    self.titleLabel.text = poi.name;
    self.addressLabel.text = poi.address;
    self.btnAppeler.hidden = [poi.phone length] == 0;
    self.distanceLabel.text = [self getDistance:poi];
}

-(IBAction)callPhone {
    [OTLogger logEvent:Action_guideMap_CallPOI];
    NSString *phone = [self.poiItem.phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:[@"tel:" stringByAppendingString:phone]]];
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
