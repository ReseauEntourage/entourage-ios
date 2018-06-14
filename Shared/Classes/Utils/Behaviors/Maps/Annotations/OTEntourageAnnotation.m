//
//  OTEntourageAnnotation.m
//  entourage
//
//  Created by Smart Care on 13/06/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTEntourageAnnotation.h"
#import "OTAppAppearance.h"
#import "UIImage+processing.h"

NSString *const kEntourageAnnotationIdentifier = @"OTEntourageAnnotationIdentifier";

@interface OTEntourageAnnotation ()
@property (nonatomic) OTEntourage *entourage;
@end

@implementation OTEntourageAnnotation

/********************************************************************************/
#pragma mark - Public methods

- (id)initWithEntourage:(OTEntourage *)entourage
{
    self = [super init];
    if (self)
    {
        self.entourage = entourage;
    }
    return self;
}

/********************************************************************************/
#pragma mark - MKAnnotation protocol

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D poiCoordinate = {
        .latitude =  self.entourage.location.coordinate.latitude,
        .longitude =  self.entourage.location.coordinate.longitude
    };
    
    return poiCoordinate;
}

- (NSString *)title
{
    return self.entourage.title;
}

- (NSString *)subtitle
{
    return self.entourage.desc;
}

- (MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self
                                                                    reuseIdentifier:kEntourageAnnotationIdentifier];
    annotationView.canShowCallout = NO;
    annotationView.image = [self annotationImage];
    annotationView.layer.cornerRadius =annotationView.image.size.width / 2;
    annotationView.clipsToBounds = YES;
    
    return annotationView;
}

- (UIImage*)annotationImage {
    CGSize imageSize = {40, 40};
    NSString *iconName = [OTAppAppearance iconNameForEntourageItem:self.entourage];
    UIImage *icon = [UIImage imageNamed:iconName];
    UIImage *container = [UIImage imageWithColor:[UIColor whiteColor] andSize:imageSize];

    CGFloat offset = (imageSize.width - icon.size.width) / 2;
    UIImage *image = [container drawImage:icon
                                   inRect:CGRectMake(offset, offset, icon.size.width, icon.size.height)];
    return image;
}

@end
