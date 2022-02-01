//
//  OTEncounterDisclaimerBehavior.m
//  entourage
//
//  Created by sergiu buceac on 9/5/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTEncounterDisclaimerBehavior.h"
#import "NSUserDefaults+OT.h"
#import "OTConsts.h"

@implementation OTEncounterDisclaimerBehavior

- (NSAttributedString *)disclaimerText {
    return [self buildDisclaimerWithLink:OTLocalizedString(@"encounter_disclaimer")];
}

@end
