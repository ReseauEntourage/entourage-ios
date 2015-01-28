//
// Created by Guillaume Lagorce on 28/01/15.
// Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import <CocoaSoundCloudAPI/SCSoundCloud.h>
#import "OTSoundCloudService.h"
#import "SCRequest.h"


NSString *const kSoundCloudUploadRoute = @"https://api.soundcloud.com/tracks.json";

@implementation OTSoundCloudService


- (void)uploadSoundAtURL:(NSURL *)soundURL
                   title:(NSString *)title
                progress:(void (^)(CGFloat percentageProgress))progress
                 success:(void (^)(NSString *uploadLocation))success
                 failure:(void (^)(NSError *error))failure {
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"track[asset_data]"] = soundURL;
	parameters[@"track[title]"] = title ? title : NSLocalizedString(@"Rencontre Entourage", @"Rencontre Entourage");
	parameters[@"track[sharing]"] = @"private";
	parameters[@"track[downloadable]"] = @"1";
	parameters[@"track[track_type]"] = @"recording";

	NSData *coverData = UIImageJPEGRepresentation([UIImage imageNamed:@"logo.png"], 0.8);
	parameters[@"track[artwork_data]"] = coverData;

	NSString *appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
	NSMutableArray *tags = [NSMutableArray array];
	[tags addObject:[NSString stringWithFormat:@"\"soundcloud:source=%@\"", appName]];

	[SCRequest   performMethod:SCRequestMethodPOST
	                onResource:[NSURL URLWithString:kSoundCloudUploadRoute]
	           usingParameters:parameters
	               withAccount:[SCSoundCloud account]
	    sendingProgressHandler: ^(unsigned long long bytesSend, unsigned long long bytesTotal)
	{
	    CGFloat percentage = (float)bytesSend / bytesTotal;
	    if (progress) {
	        progress(percentage);
		}
	}

	           responseHandler: ^(NSURLResponse *response, NSData *data, NSError *error)
	{
	    NSError *jsonError = nil;
	    NSDictionary *result = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError] : nil;

	    if (error) {
	        NSLog(@"Upload failed with error : %@", error);
	        if (failure) {
	            failure(error);
			}
		}
	    else if (jsonError) {
	        NSLog(@"Upload failed with json error: %@", jsonError);
	        if (failure) {
	            failure(error);
			}
		}
	    else {
	        NSLog(@"Upload successful at location : %@", result[@"uri"]);
	        if (success) {
	            success(result[@"uri"]);
			}
		}
	}

	];
}

@end
