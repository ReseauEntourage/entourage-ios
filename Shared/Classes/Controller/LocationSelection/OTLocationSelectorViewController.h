//
//  OTLocationSelectorViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 07/06/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol HandleMapSearch <NSObject>

- (void)dropPinZoomIn:(MKPlacemark*)placemark;

@end

@protocol LocationSelectionDelegate <NSObject>

- (void)didSelectLocation:(CLLocation *)location;

@end

@interface OTLocationSelectorViewController : UIViewController<HandleMapSearch>

@property (nonatomic, strong) CLLocation *selectedLocation;
@property (nonatomic, weak) id<LocationSelectionDelegate> locationSelectionDelegate;

@end
