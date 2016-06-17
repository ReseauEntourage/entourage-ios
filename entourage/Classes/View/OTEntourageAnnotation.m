//
//  OTEntourageAnnotation.m
//  entourage
//
//  Created by Ciprian Habuc on 17/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageAnnotation.h"

#import "OTEntourage.h"
#import "UIImage+entourage.h"

@implementation OTEntourageAnnotation

/********************************************************************************/
#pragma mark - Public methods

- (id)initWithEntourage:(OTEntourage *)entourage
{
    self = [super init];
    if (self)
    {
        self.entourage = entourage;
        self.scale = 1.0;
    }
    return self;
}

- (id)initWithEntourage:(OTEntourage *)entourage andScale:(double)scale
{
    self = [super init];
    if (self)
    {
        self.entourage = entourage;
        self.scale = scale;
    }
    return self;
}

/********************************************************************************/
#pragma mark - MKAnnotation protocol

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D poiCoordinate = { .latitude =  self.entourage.location.coordinate.latitude, .longitude =  self.entourage.location.coordinate.longitude };
    return poiCoordinate;
}

- (NSString *)title
{
    return self.entourage.title;
}

- (NSString *)subtitle
{
    return self.entourage.description;
}
@end
