//
//  OTMapCell.h
//  entourage
//
//  Created by sergiu buceac on 10/12/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OTMapAnnotationProviderBehavior.h"
#import "OTBaseInfoCell.h"

@interface OTMapCell : OTBaseInfoCell

@property (nonatomic, weak) IBOutlet MKMapView *map;
@property (nonatomic, weak) IBOutlet OTMapAnnotationProviderBehavior *annotationProvider;

@end
