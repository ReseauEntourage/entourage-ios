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

    [OTCrashlyticsHelper recordError:@"OTGroupSharingFormatter: Unhandled groupType" ];

    return group.shareUrl;
}

+ (NSString *)actionShareText:(OTEntourage *)action {
    NSString *tempStr = [NSString stringWithFormat:OTLocalizedString(@"share_action"), action.shareUrl];
   
    return tempStr;
}

+ (NSString *)eventShareText:(OTEntourage *)event {
    NSString *tempStr = [NSString stringWithFormat:OTLocalizedString(@"share_action"), event.shareUrl];
   
    return tempStr;
}

+ (NSString *)genericShareText:(OTEntourage *)group {
    NSString *template_name = [NSString stringWithFormat:@"%@share_generic", self.communityPrefix];
    NSString *template = OTLocalizedString(template_name);
    return [NSString stringWithFormat:template, group.title, group.shareUrl];
}

NSString *const prefixEntourage = @"";

+ (NSString *)communityPrefix {
    if ([OTAppConfiguration isApplicationTypeEntourage])
        return prefixEntourage;
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
