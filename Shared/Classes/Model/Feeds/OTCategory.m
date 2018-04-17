//
//  OTCategory.m
//  entourage
//
//  Created by veronica.gliga on 24/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTCategory.h"

@implementation OTCategory

+ (NSDictionary *)createDictionary {
    return  @{@"social":@(OTSocial),
              @"event":@(OTEvent),
              @"mat_help":@(OTHelp),
              @"resource":@(OTResource),
              @"info":@(OTInfo),
              @"skill":@(OTSkill),
              @"other":@(OTOther)
              };
}

@end
