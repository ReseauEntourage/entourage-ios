//
//  OTEntourageAnnotation.h
//  entourage
//
//  Created by Smart Care on 13/06/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "OTEntourage.h"

extern NSString *const kEntourageAnnotationIdentifier;

@interface OTEntourageAnnotation : NSObject <MKAnnotation>
- (id)initWithEntourage:(OTEntourage *)entourage;
- (MKAnnotationView *)annotationView;
@end
