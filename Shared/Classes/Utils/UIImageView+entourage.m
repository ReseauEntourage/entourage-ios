//
//  UIImageView+entourage.m
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIImageView+entourage.h"

@implementation UIImageView (entourage)

- (void)setupFromUrl:(NSString *)url withPlaceholder:(NSString *)placeholder {
    __weak UIImageView *imageView = self;
    UIImage *placeholderImage = [UIImage imageNamed:placeholder];
    if (url != nil && [url class] != [NSNull class] && url.length > 0) {
        NSURL *imgUrl = [NSURL URLWithString:url];
        [imageView setImageWithURL:imgUrl placeholderImage:placeholderImage];
    }
    else
        imageView.image = placeholderImage;
}

@end
