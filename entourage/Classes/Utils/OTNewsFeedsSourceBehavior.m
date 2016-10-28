//
//  OTNewsFeedsSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 10/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTNewsFeedsSourceBehavior.h"

@implementation OTNewsFeedsSourceBehavior

- (void)updateOnFilterChange {
    [self.delegate clearData];
}

#pragma mark - private methods

- (void)requestData {
    
}

- (void)callSelectorOnDelegateSafe:(SEL)selector {
    if([self.delegate respondsToSelector:selector])
       [self.delegate performSelector:selector];
}

@end
