//
//  OTEntourageAnnotationView.m
//  entourage
//
//  Created by sergiu buceac on 6/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageAnnotationView.h"

NSString *const kEntourageAnnotationIdentifier = @"OTEntourageAnnotationIdentifier";

#define ImageTag 1234

@interface OTEntourageAnnotationView () {
    float originalSize;
}

@property (nonatomic) CGFloat scale;

@end

@implementation OTEntourageAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self) {
        self.scale = 1;
        [self setup];
    }
    return self;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier andScale:(CGFloat)scale {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self) {
        self.scale = scale;
        [self setup];
    }
    return self;
}

- (void)setup {
    self.canShowCallout = NO;
    self.image = nil;
    [self addImage];
    [self updateScale:self.scale];
}

- (void)addImage {
    UIImageView* imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heatZone.png"]];
    imgView.tag = ImageTag;
    [self addSubview:imgView];
    originalSize = imgView.image.size.width;
}

- (void)updateScale:(CGFloat)scale {
    self.scale = scale;
    [self updateAnnotationScale];
    [self repositionImage];
}

- (void)updateAnnotationScale {
    float size = originalSize * self.scale;
    CGRect frame = self.frame;
    frame.size.width = size;
    frame.size.height = size;
    self.frame = frame;
}

-(void)repositionImage {
    UIImageView* img = [self viewWithTag:ImageTag];
    img.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

@end
