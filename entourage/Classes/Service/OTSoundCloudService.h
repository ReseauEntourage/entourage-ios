//
// Created by Guillaume Lagorce on 28/01/15.
// Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OTSoundCloudService : NSObject

- (void)uploadSoundAtURL:(NSURL *)soundURL
                   title:(NSString *)title
                progress:(void (^)(CGFloat percentageProgress))progress
                 success:(void (^)(NSString *uploadLocation))success
                 failure:(void (^)(NSError *error))failure;

@end