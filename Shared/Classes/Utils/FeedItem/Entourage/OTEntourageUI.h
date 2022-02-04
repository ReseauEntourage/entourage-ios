//
//  OTEntourageUI.h
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTEntourageFactory.h"
#import "OTUIDelegate.h"

@interface OTEntourageUI : OTEntourageFactory<OTUIDelegate>

- (NSString *)formattedDaysIntervalFromToday:(NSDate *)date;

@end
