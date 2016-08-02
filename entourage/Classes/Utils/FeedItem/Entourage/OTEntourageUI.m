//
//  OTEntourageUI.m
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageUI.h"
#import "OTConsts.h"

@implementation OTEntourageUI

- (NSAttributedString *)descriptionWithSize:(CGFloat)size {
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:OTLocalizedString(@"formater_by"), OTLocalizedString(self.entourage.type).capitalizedString] attributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size]}];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:self.entourage.author.displayName attributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_BOLD_DESCRIPTION size:size]}];
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:nameAttrString];
    return typeByNameAttrString;
}

- (NSString *)displayType {
    return OTLocalizedString(self.entourage.type);
}

@end
