//
//  OTPictureUploadService.h
//  entourage
//
//  Created by sergiu buceac on 7/13/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTPictureUploadService : NSObject

+ (void)configure;

- (void)uploadPicture:(UIImage *)picture withSuccess:(void(^)(NSString *))success orError:(void(^)())error;

@end
