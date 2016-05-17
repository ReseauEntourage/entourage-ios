//
//  OTEntourageAnnotation.h
//  entourage
//
//  Created by Ciprian Habuc on 17/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class OTEntourage;

extern NSString *const kEntourageAnnotationIdentifier;
extern NSString *const kEntourageClusterAnnotationIdentifier;

@interface OTEntourageAnnotation : NSObject <MKAnnotation>

- (id)initWithEntourage:(OTEntourage *)entourage;
- (MKAnnotationView *)annotationView;

@property (nonatomic, strong) OTEntourage *entourage;

@end
