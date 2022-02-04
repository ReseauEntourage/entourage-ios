//
//  OTOngoingTourService.m
//  entourage
//
//  Created by sergiu buceac on 9/2/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTOngoingTourService.h"

@implementation OTOngoingTourService

+ (OTOngoingTourService*)sharedInstance {
    static OTOngoingTourService* sharedInstance;
    static dispatch_once_t tourServiceToken;
    dispatch_once(&tourServiceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

@end
