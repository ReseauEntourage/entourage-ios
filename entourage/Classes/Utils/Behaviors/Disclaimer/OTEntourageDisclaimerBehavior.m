//
//  OTEntourageDisclaimerBehavior.m
//  entourage
//
//  Created by sergiu buceac on 9/5/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageDisclaimerBehavior.h"
#import "NSUserDefaults+OT.h"
#import "OTConsts.h"

@implementation OTEntourageDisclaimerBehavior

- (NSAttributedString *)disclaimerText {
    return [self buildDisclaimerWithLink:OTLocalizedString(@"entourage_disclaimer")];
}

- (BOOL)wasDisclaimerAccepted {
    return [NSUserDefaults wasEntourageDisclaimerAccepted];
}

- (NSString *)disclaimerStorageKey {
    return kEntourageDisclaimer;
}

@end
