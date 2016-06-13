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

NSString *const kEntourageAnnotationIdentifier = @"OTEntourageAnnotationIdentifier";
NSString *const kEntourageClusterAnnotationIdentifier = @"OTEntourageClusterAnnotationIdentifier";

@interface OTEntourageAnnotation () <MKAnnotation>

@property (nonatomic) CGFloat scale;

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
        _scale = 1.0;
    }
    return self;
}

- (id)initWithEntourage:(OTEntourage *)entourage andScale:(double)scale
{
    self = [super init];
    if (self)
    {
        _entourage = entourage;
        _scale = scale;
    }
    return self;
}

/********************************************************************************/
#pragma mark - MKAnnotation protocol

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D poiCoordinate = { .latitude =  self.entourage.location.coordinate.latitude,
                                            .longitude =  self.entourage.location.coordinate.longitude };
    
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


- (MKAnnotationView *)annotationView
{
    UIImage *scaledImage = [UIImage imageNamed:@"heatZone"
                                     withScale:self.scale];
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self
                                                                    reuseIdentifier:nil];//kEntourageAnnotationIdentifier];
    
    annotationView.canShowCallout = NO;
    annotationView.image = scaledImage;
    
    return annotationView;
}

@end
