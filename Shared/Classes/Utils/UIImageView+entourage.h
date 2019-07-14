//
//  UIImageView+entourage.h
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (entourage)

- (void)setupFromUrl:(NSString *)url withPlaceholder:(NSString *)placeholder;
- (void)setupFromUrl:(NSString *)url withPlaceholder:(NSString * _Nullable)placeholder
             success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
             failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
