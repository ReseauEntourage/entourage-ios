//
//  OTCustomAnnotation.h
//  entourage
//
//  Created by Guillaume Lagorce on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@class OTPoi;

extern NSString *const kAnnotationIdentifier;

@interface OTCustomAnnotation : NSObject <MKAnnotation>

- (id)initWithPoi:(OTPoi *)poi;
- (MKAnnotationView *)annotationView;

@property (nonatomic, strong) OTPoi *poi;

@end
