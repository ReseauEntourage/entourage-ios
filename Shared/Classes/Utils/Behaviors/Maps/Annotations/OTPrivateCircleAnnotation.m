//
//  OTPrivateCircleAnnotation.m
//  entourage
//
//  Created by Smart Care on 27/06/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import "OTPrivateCircleAnnotation.h"
#import "UIImage+processing.h"

NSString *const kPrivateCircleAnnotationIdentifier = @"OTPrivateCircleAnnotationIdentifier";

@implementation OTPrivateCircleAnnotation

- (UIImage*)annotationImage {
    NSString *iconName = @"private-circle";
    return [self annotationImageWithName:iconName];
}

- (MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self
                                                                    reuseIdentifier:kPrivateCircleAnnotationIdentifier];
    annotationView.canShowCallout = NO;
    annotationView.image = [self annotationImage];
    annotationView.layer.cornerRadius =annotationView.image.size.width / 2;
    annotationView.clipsToBounds = YES;
    
    return annotationView;
}

@end
