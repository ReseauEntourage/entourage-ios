//
//  NSAttributedString+OTBuilder.m
//  entourage
//
//  Created by sergiu buceac on 11/15/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "NSAttributedString+OTBuilder.h"

@implementation NSAttributedString (OTBuilder)

+ (void)applyLinkOnTextView:(UITextView *)textView
                   withText:(NSString *)text
                 toLinkText:(NSString *)linkString
                   withLink:(NSString *)link {
    textView.linkTextAttributes = @{NSForegroundColorAttributeName: textView.textColor,
                                    NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
    textView.attributedText = [NSAttributedString createLinkStringFor:text
                                                             linkPart:linkString
                                                                 font:textView.font
                                                             andColor:textView.textColor
                                                             withLink:link];
}

+ (NSAttributedString *)buildLinkForTextView:(UITextView *)textView withText:(NSString *)text toLinkText:(NSString *)linkString withLink:(NSString *)link {
    textView.linkTextAttributes = @{NSForegroundColorAttributeName: textView.textColor, NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
    return [NSAttributedString createLinkStringFor:text linkPart:linkString font:textView.font andColor:textView.textColor withLink:link];
}

+ (NSAttributedString *)createLinkStringFor:(NSString *)string
                                   linkPart:(NSString *)linkPart
                                       font:(UIFont *)font
                                   andColor:(UIColor *)color
                                   withLink:(NSString *)link {
    NSRange range = [string rangeOfString:linkPart];
    NSMutableAttributedString *source = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange fullRange = NSMakeRange(0, string.length);
    [source addAttribute:NSFontAttributeName value:font range:fullRange];
    [source addAttribute:NSForegroundColorAttributeName value:color range:fullRange];
    
    if (range.location != NSNotFound) {
        [source addAttribute:NSLinkAttributeName value:link range:range];
        [source addAttribute:NSFontAttributeName value:font range:fullRange];
        [source addAttribute:NSForegroundColorAttributeName value:color range:fullRange];
        [source addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
        [source addAttribute:NSUnderlineColorAttributeName value:color range:range];
    }
    
    return source;
}

@end
