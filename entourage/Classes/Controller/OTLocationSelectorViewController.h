//
//  OTLocationSelectorViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 07/06/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol HandleMapSearch <NSObject>

- (void)dropPinZoomIn:(MKPlacemark*)placemark;

@end


@interface OTLocationSelectorViewController : UIViewController<HandleMapSearch>

@property (nonatomic, assign) CLLocationCoordinate2D selectedCoordinate;

@end
