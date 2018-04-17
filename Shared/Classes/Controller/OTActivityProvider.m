//
//  OTActivityProvider.m
//  entourage
//
//  Created by veronica.gliga on 08/12/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTActivityProvider.h"
#import "OTConsts.h"

@implementation OTActivityProvider

- (id)initWithPlaceholderItem:(id)placeholderItem
{
    return [super initWithPlaceholderItem:placeholderItem];
}

- (id)item
{
    return [NSDictionary dictionary];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(UIActivityType)activityType {
    if ([activityType isEqualToString: UIActivityTypeCopyToPasteboard]) {
        return self.url;
    }
    else if ([activityType isEqualToString:UIActivityTypeMail]) {
        return @{@"body":self.emailBody};
    }
    else if ([activityType isEqualToString:@"com.google.Gmail.ShareExtension"])
        return @{@"body":self.emailBody, @"url":self.url};
    return self.emailBody;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(UIActivityType)activityType
{
    return @"";
}

@end
