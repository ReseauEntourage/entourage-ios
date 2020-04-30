//
//  OTGroupSharingFormatter.m
//  entourage
//
//  Created by Grégoire Clermont on 06/02/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

#import "OTGroupSharingFormatter.h"
#import "OTAppConfiguration.h"
#import "OTCrashlyticsHelper.h"
#import "NSUserDefaults+OT.h"

@implementation OTGroupSharingFormatter

+ (NSString *)groupShareText:(OTEntourage *)group {
    if (group.isAction)
        return [self actionShareText:group];
    if (group.isOuting)
        return [self eventShareText:group];
    if (group.isPrivateCircle || group.isNeighborhood)
        return [self genericShareText:group];

    [OTCrashlyticsHelper
     recordError:@"OTGroupSharingFormatter: Unhandled groupType"
     userInfo:@{
         @"groupType": group.groupType
     }];

    return group.shareUrl;
}

+ (NSString *)actionShareText:(OTEntourage *)action {
    NSString *template_name = [NSString stringWithFormat:@"%@share_action", self.communityPrefix];
    NSString *template = OTLocalizedString(template_name);
    NSString *role = [self actionRole:action];
    NSString *verb_name = [NSString stringWithFormat:@"share_action_verb_%@", role];
    NSString *verb = OTLocalizedString(verb_name);
    return [NSString stringWithFormat:template, verb, action.title, action.shareUrl];
}

+ (NSString *)eventShareText:(OTEntourage *)event {
    NSString *template_name = [NSString stringWithFormat:@"%@share_event", self.communityPrefix];
    NSString *template = OTLocalizedString(template_name);
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
    [dateFormatter setDateFormat:@"EEEE d MMMM à H'h'mm"];
    NSString *date = [dateFormatter stringFromDate:event.startsAt];
    
    return [NSString stringWithFormat:template, event.title, date, event.displayAddress, event.shareUrl];
}

+ (NSString *)genericShareText:(OTEntourage *)group {
    NSString *template_name = [NSString stringWithFormat:@"%@share_generic", self.communityPrefix];
    NSString *template = OTLocalizedString(template_name);
    return [NSString stringWithFormat:template, group.title, group.shareUrl];
}

NSString *const prefixEntourage = @"";
NSString *const prefixPfp       = @"pfp_";

+ (NSString *)communityPrefix {
    if ([OTAppConfiguration isApplicationTypeEntourage])
        return prefixEntourage;
    if ([OTAppConfiguration isApplicationTypeVoisinAge])
        return prefixPfp;
    @throw @"Unknown community";
}


NSString *const roleCreator = @"creator";
NSString *const roleMember  = @"member";
NSString *const roleOther   = @"other";

+ (NSString *)actionRole:(OTEntourage *)action {
    if ([action.author.uID isEqualToNumber:[NSUserDefaults standardUserDefaults].currentUser.sid])
        return roleCreator;
    if ([action.joinStatus isEqualToString:JOIN_ACCEPTED])
        return roleMember;
    else
        return roleOther;
}
@end
