//
//  OTEntourageAnnotation.m
//  entourage
//
//  Created by Ciprian Habuc on 17/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageAnnotation.h"

#import "OTEntourage.h"

NSString *const kEntourageAnnotationIdentifier = @"OTEntourageAnnotationIdentifier";
NSString *const kEntourageClusterAnnotationIdentifier = @"OTEntourageClusterAnnotationIdentifier";

@interface OTEntourageAnnotation () <MKAnnotation>

@end

@implementation OTEntourageAnnotation

/********************************************************************************/
#pragma mark - Public methods

- (id)initWithEntourage:(OTEntourage *)entourage
{
    self = [super init];
    if (self)
    {
        _entourage = entourage;
    }
    return self;
}

/********************************************************************************/
#pragma mark - MKAnnotation protocol

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D poiCoordinate = { .latitude =  self.entourage.latitude.doubleValue, .longitude =  self.entourage.longitude.doubleValue };
    
    return poiCoordinate;
}

- (NSString *)title
{
    return self.entourage.name;
}

- (NSString *)subtitle
{
    return self.entourage.description;
}

- (MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self
                                                                    reuseIdentifier:kEntourageAnnotationIdentifier];
    
    annotationView.canShowCallout = NO;
    annotationView.image = [UIImage imageNamed:@"heatZone"];
    
    return annotationView;
}



@end
