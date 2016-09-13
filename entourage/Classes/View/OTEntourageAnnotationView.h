//
//  OTEntourageAnnotationView.h
//  entourage
//
//  Created by sergiu buceac on 6/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

extern NSString *const kEntourageAnnotationIdentifier;

@interface OTEntourageAnnotationView : MKAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier andScale:(CGFloat)scale;
- (void)updateScale:(CGFloat)scale;

@end
