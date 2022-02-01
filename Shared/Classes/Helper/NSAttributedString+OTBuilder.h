//
//  NSAttributedString+OTBuilder.h
//  entourage
//
//  Created by sergiu buceac on 11/15/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (OTBuilder)

+ (void)applyLinkOnTextView:(UITextView *)textView withText:(NSString *)text toLinkText:(NSString *)linkString withLink:(NSString *)link;
+ (NSAttributedString *)buildLinkForTextView:(UITextView *)textView withText:(NSString *)text toLinkText:(NSString *)linkString withLink:(NSString *)link;

@end
