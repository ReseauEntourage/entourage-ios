//
//  OTOngoingTourService.h
//  entourage
//
//  Created by sergiu buceac on 9/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTOngoingTourService : NSObject

+ (OTOngoingTourService*) sharedInstance;

@property (nonatomic) BOOL isOngoing;

@end
