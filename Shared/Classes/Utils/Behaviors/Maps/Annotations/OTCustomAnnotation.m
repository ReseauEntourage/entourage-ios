//
//  OTCustomAnnotation.m
//  entourage
//
//  Created by Guillaume Lagorce on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTCustomAnnotation.h"

// Model
#import "OTPoi.h"

// Framework
#import <MapKit/MKMapView.h>

NSString *const kAnnotationIdentifier = @"OTAnnotationIdentifier";

@interface OTCustomAnnotation () <MKAnnotation>

@end

@implementation OTCustomAnnotation

/********************************************************************************/
#pragma mark - Public methods

- (id)initWithPoi:(OTPoi *)poi
{
	self = [super init];
	if (self)
	{
		_poi = poi;
	}
	return self;
}

/********************************************************************************/
#pragma mark - MKAnnotation protocol

- (CLLocationCoordinate2D)coordinate
{
	CLLocationCoordinate2D poiCoordinate = { .latitude =  self.poi.latitude, .longitude =  self.poi.longitude };

	return poiCoordinate;
}

- (NSString *)title
{
	return self.poi.name;
}

- (NSString *)subtitle
{
	return self.poi.details;
}

- (MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:kAnnotationIdentifier];

	annotationView.canShowCallout = NO;
	annotationView.image = self.poi.image;

	return annotationView;
}

- (NSString *)annotationIdentifier
{
    return [NSString stringWithFormat:@"%@-%@", kAnnotationIdentifier, self.poi.categoryId];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[OTCustomAnnotation class]]) {
        OTCustomAnnotation *compare = (OTCustomAnnotation *) object;
        if (_poi.sid != nil && compare.poi.sid != nil) {
            return _poi.sid.longValue == compare.poi.sid.longValue;
        } else {
            return false;
        }
    } else {
        return false;
    }
    
}

@end
