//
//  OTTextView.h
//  entourage
//
//  Created by Ciprian Habuc on 11/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UILabel *placeholderLabel;

- (void)showCharCount;
- (void)updateAfterSpeech;

@end
