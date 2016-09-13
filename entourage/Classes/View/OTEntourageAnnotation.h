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

@interface OTEntourageAnnotation : NSObject <MKAnnotation>

- (id)initWithEntourage:(OTEntourage *)entourage;
- (id)initWithEntourage:(OTEntourage *)entourage andScale:(double)scale;

@property (nonatomic, strong) OTEntourage *entourage;
@property (nonatomic) CGFloat scale;

@end
