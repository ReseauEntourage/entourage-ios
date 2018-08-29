//
//  OTNeighborhoodAnnotation.m
//  entourage
//
//  Created by Smart Care on 27/06/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTNeighborhoodAnnotation.h"
#import "UIImage+processing.h"

NSString *const kNeighborhoodAnnotationIdentifier = @"OTNeighborhoodAnnotationIdentifier";

@implementation OTNeighborhoodAnnotation

- (UIImage*)annotationImage {
    NSString *iconName = @"neighborhood";
    return [self annotationImageWithName:iconName];
}

- (MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self
                                                                    reuseIdentifier:kNeighborhoodAnnotationIdentifier];
    annotationView.canShowCallout = NO;
    annotationView.image = [self annotationImage];
    annotationView.layer.cornerRadius =annotationView.image.size.width / 2;
    annotationView.clipsToBounds = YES;
    
    return annotationView;
}

@end
