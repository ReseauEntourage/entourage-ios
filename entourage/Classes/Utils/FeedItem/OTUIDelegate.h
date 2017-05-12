//
//  OTUIDelegate.h
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FONT_NORMAL_DESCRIPTION @"SFUIText-Light"
#define FONT_BOLD_DESCRIPTION @"SFUIText-Bold"
#define DEFAULT_DESCRIPTION_SIZE 15.0

@protocol OTUIDelegate <NSObject>

- (NSAttributedString *) descriptionWithSize:(CGFloat)size;
- (NSString *)summary;
- (NSString *)feedItemDescription;
- (NSString *)navigationTitle;
- (NSString *)joinAcceptedText;
- (double)distance;
- (BOOL)isStatusBtnVisible;

@end
