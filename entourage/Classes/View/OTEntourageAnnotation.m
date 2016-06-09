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

@property (nonatomic) double scale;

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
/*
 
 let image = UIImage(contentsOfFile: self.URL.absoluteString!)
 
 let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.5, 0.5))
 let hasAlpha = false
 let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
 
 UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
 image.drawInRect(CGRect(origin: CGPointZero, size: size))
 
 let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
 UIGraphicsEndImageContext()
 
 */


- (MKAnnotationView *)annotationView
{
    UIImage *image = [UIImage imageNamed:@"heatZone"];
    CGSize size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(_scale, _scale));
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:nil];
                                                                    //reuseIdentifier:kEntourageAnnotationIdentifier];
    
    annotationView.canShowCallout = NO;
    annotationView.image = scaledImage;//[UIImage imageNamed:@"heatZone"];
    
    return annotationView;
}



@end
