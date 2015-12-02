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

@interface OTCustomAnnotation : NSObject <MKAnnotation>

- (id)initWithPoi:(OTPoi *)poi;
- (MKAnnotationView *)annotationView;
- (NSString *)annotationIdentifier;
- (BOOL)isEqual:(id)object;

@property (nonatomic, strong) OTPoi *poi;

@end
