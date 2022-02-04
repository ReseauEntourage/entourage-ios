//
//  UIImageView+entourage.m
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 Entourage. All rights reserved.
//
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIImageView+entourage.h"
#import <SDWebImage/SDWebImage.h>

@implementation UIImageView (entourage)

- (void)setupFromUrl:(NSString *)url withPlaceholder:(NSString *)placeholder {
    __weak UIImageView *imageView = self;
    UIImage *placeholderImage = [UIImage imageNamed:placeholder];
    if (url != nil && [url class] != [NSNull class] && url.length > 0) {
        NSURL *imgUrl = [NSURL URLWithString:url];
        [imageView sd_setImageWithURL:imgUrl placeholderImage:placeholderImage];
    }
    else
        imageView.image = placeholderImage;
}

- (void)setupFromUrl:(NSString *)url withPlaceholder:(NSString *)placeholder
             success:(void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
             failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure {

    __weak UIImageView *imageView = self;
    UIImage *placeholderImage = [UIImage imageNamed:placeholder];
    if (url != nil && [url class] != [NSNull class] && url.length > 0) {
        NSURL *imgUrl = [NSURL URLWithString:url];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imgUrl];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        [self setImageWithURLRequest:request placeholderImage:placeholderImage success:success failure:failure];
    }
    else
        imageView.image = placeholderImage;
}

@end
