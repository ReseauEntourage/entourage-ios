//
//  OTOutingAnnotation.m
//  entourage
//
//  Created by Smart Care on 04/07/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTOutingAnnotation.h"
#import "UIImage+processing.h"
#import "entourage-Swift.h"

NSString *const kOutingAnnotationIdentifier = @"OTOutingAnnotationIdentifier";

@implementation OTOutingAnnotation

- (MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self
                                                                    reuseIdentifier:kOutingAnnotationIdentifier];
    annotationView.canShowCallout = NO;
    annotationView.image = [self annotationImage];
    annotationView.layer.cornerRadius =annotationView.image.size.width / 2;
    annotationView.clipsToBounds = YES;
    
    return annotationView;
}

@end
