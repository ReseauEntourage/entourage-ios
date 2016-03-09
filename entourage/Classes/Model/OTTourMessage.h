//
//  OTTourMessage.h
//  entourage
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTTourTimelinePoint.h"

@interface OTTourMessage : OTTourTimelinePoint

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *userAvatarURL;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
