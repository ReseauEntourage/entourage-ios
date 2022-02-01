//
//  OTEntourageAnnotation.m
//  entourage
//
//  Created by Smart Care on 13/06/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import "OTEntourageAnnotation.h"
#import "OTAppAppearance.h"
#import "UIImage+processing.h"
#import "entourage-Swift.h"

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
    NSString *iconName = [OTAppAppearance iconNameForEntourageItem:self.entourage isAnnotation:YES];
   
    return [self annotationImageWithName:iconName isOuting:self.entourage.isOuting];
}

- (UIImage*)annotationImageWithName:(NSString*)iconName isOuting:(BOOL) isOuting {
    if (isOuting) {
        UIImage *icon = [UIImage imageNamed:iconName];
        
        return icon;
    }
    
    CGSize imageSize = {40, 40};
    UIImage *icon = [UIImage imageNamed:iconName];
    
    UIImage *container = [UIImage imageWithColor:[UIColor whiteColor] andSize:imageSize];
    
    CGFloat offseY = (imageSize.height - icon.size.height) / 2;
    CGFloat offseX = (imageSize.width - icon.size.width) / 2;
    UIImage *image = [container drawImage:icon
                                   inRect:CGRectMake(offseX, offseY, icon.size.width, icon.size.height)];
    return image;
}

@end
