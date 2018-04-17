//
//  OTTextView.m
//  entourage
//
//  Created by veronica.gliga on 11/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTTextView.h"
#import "OTTapViewBehavior.h"

#define LARGE_PLACEHOLDER_FONT [UIFont fontWithName:@"SFUIText-Light" size:13]
#define LARGE_PLACEHOLDER_INSETS 13
#define ANIMATION_DURATION 0.25f
#define COUNT_LABEL_OFFSET 30

@interface OTTextView () <UITextViewDelegate>

@end

@implementation OTTextView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.placeholderLabel = [UILabel new];
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.hidden = YES;
    [self addSubview:self.placeholderLabel];
    self.delegate = self;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.hidden = NO;
    [self.placeholderLabel setText:placeholder];
    [self showLargePlaceholder];
}

- (void)showLargePlaceholder {
    self.placeholderLabel.text = self.placeholder;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.placeholderLabel.font = LARGE_PLACEHOLDER_FONT;
        self.placeholderLabel.textColor = self.placeholderLargeColor;
        self.placeholderLabel.frame = self.largePlaceholderFrame;
    } completion:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.placeholderLabel.text = self.editingPlaceholder;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.forwardDelegate textViewDidChange:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.text.length == 0)
        [self setPlaceholder:self.placeholder];
    
    else
        self.placeholderLabel.text = self.editingPlaceholder;
}

#pragma mark - layout and drawing

- (void)layoutSubviews {
    [super layoutSubviews];
    if(self.computedFrames)
        return;
    self.computedFrames = YES;
    
    if(!self.placeholder)
        return;
    
    CGFloat insetedWidth = self.frame.size.width - 2 * LARGE_PLACEHOLDER_INSETS;
    CGRect maxAvailableEditing = CGRectMake(LARGE_PLACEHOLDER_INSETS, LARGE_PLACEHOLDER_INSETS, insetedWidth, self.frame.size.height - LARGE_PLACEHOLDER_INSETS - COUNT_LABEL_OFFSET);
    
    CGRect largeMaxSize = [self.placeholder boundingRectWithSize:maxAvailableEditing.size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: LARGE_PLACEHOLDER_FONT} context:nil];
    self.largePlaceholderFrame = CGRectMake(LARGE_PLACEHOLDER_INSETS, LARGE_PLACEHOLDER_INSETS, insetedWidth, largeMaxSize.size.height);
    
    self.placeholderLabel.frame = self.largePlaceholderFrame;
    
}

@end
