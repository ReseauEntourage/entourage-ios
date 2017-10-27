//
//  OTTextWithCount.m
//  entourage
//
//  Created by sergiu buceac on 10/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTextWithCount.h"
#import "UIColor+entourage.h"

#define LARGE_PLACEHOLDER_FONT [UIFont fontWithName:@"SFUIText-Light" size:15]
#define SMALL_PLACEHOLDER_FONT [UIFont fontWithName:@"SFUIText-Light" size:9]
#define TEXTVIEW_FONT [UIFont fontWithName:@"SFUIText-Light" size:15]
#define CHAR_COUNT_FONT [UIFont fontWithName:@"SFUIText-Light" size:12]
#define TEXTVIEW_COLOR [UIColor appGreyishBrownColor]
#define ANIMATION_DURATION 0.25f
#define LARGE_PLACEHOLDER_INSETS 15
#define SMALL_PLACEHOLDER_INSETS 3
#define COUNT_LABEL_OFFSET 30

@interface OTTextWithCount () <UITextViewDelegate>

@property (nonatomic, assign) BOOL computedFrames;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *charCountLabel;
@property (nonatomic, assign) BOOL showCount;
@property (nonatomic, assign) CGRect largePlaceholderFrame;
@property (nonatomic, assign) CGRect smallPlaceholderFrame;
@property (nonatomic, assign) CGRect largeTextviewFrame;
@property (nonatomic, assign) CGRect smallTextviewFrame;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation OTTextWithCount

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.placeholderLabel.textColor = self.placeholderSmallColor;
}

- (void)initialize {
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self addGestureRecognizer:self.tapGesture];
    
    self.textView = [UITextView new];
    self.textView.font = TEXTVIEW_FONT;
    self.textView.textColor = TEXTVIEW_COLOR;
    [self addSubview:self.textView];
    self.textView.delegate = self;
    
    self.placeholderLabel = [UILabel new];
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.hidden = YES;
    [self addSubview:self.placeholderLabel];
    
    self.charCountLabel = [UILabel new];
    self.charCountLabel.font = CHAR_COUNT_FONT;
    self.charCountLabel.hidden = YES;
    [self addSubview:self.charCountLabel];
}

- (void)updateAfterSpeech {
    [self showSmallPlaceholder];
    [self updateLabelCount];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.hidden = NO;
    self.placeholderLabel.text = placeholder;
    [self showLargePlaceholder];
}

- (void)setMaxLength:(int)maxLength {
    _maxLength = maxLength;
    self.showCount = maxLength > 0;
    self.charCountLabel.hidden = !self.showCount;
    self.charCountLabel.textColor = self.placeholderLargeColor;
    [self updateLabelCount];
}

- (void)tapped {
    [self.textView becomeFirstResponder];
}

- (void)updateLabelCount {
    if(!self.showCount)
        return;
    self.charCountLabel.text = [NSString stringWithFormat:@"%u/%d", (int)self.textView.text.length, self.maxLength];
    if(self.maxLength > 0) {
        UIColor *current = self.maxLength <= self.textView.text.length ? UIColor.maxLenghtReachedColor : self.placeholderLargeColor;
        self.charCountLabel.textColor = current;
    }
    if(self.delegate)
        [self.delegate maxLengthReached:(self.maxLength <= self.textView.text.length)];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self showSmallPlaceholder];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateLabelCount];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.textView.text.length == 0)
        [self showLargePlaceholder];
    else
        [self showSmallPlaceholder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if(!self.showCount)
        return YES;
    return self.textView.text.length - range.length + text.length <= self.maxLength;
}

#pragma mark - placeholder management

- (void)showSmallPlaceholder {
    self.placeholderLabel.text = self.editingPlaceholder;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.placeholderLabel.font = SMALL_PLACEHOLDER_FONT;
        self.placeholderLabel.textColor = self.placeholderSmallColor;
        self.placeholderLabel.frame = self.smallPlaceholderFrame;
        self.textView.frame = self.smallTextviewFrame;
    } completion:nil];
}

- (void)showLargePlaceholder {
    self.placeholderLabel.text = self.placeholder;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.placeholderLabel.font = LARGE_PLACEHOLDER_FONT;
        self.placeholderLabel.textColor = self.placeholderLargeColor;
        self.placeholderLabel.frame = self.largePlaceholderFrame;
        self.textView.frame = self.largeTextviewFrame;
    } completion:nil];
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
    self.largeTextviewFrame = CGRectMake(LARGE_PLACEHOLDER_INSETS, LARGE_PLACEHOLDER_INSETS, insetedWidth, self.frame.size.height - LARGE_PLACEHOLDER_INSETS - COUNT_LABEL_OFFSET);
    
    CGRect smallMaxSize = [self.editingPlaceholder boundingRectWithSize:maxAvailableEditing.size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: SMALL_PLACEHOLDER_FONT} context:nil];
    self.smallPlaceholderFrame = CGRectMake(LARGE_PLACEHOLDER_INSETS, SMALL_PLACEHOLDER_INSETS, insetedWidth, smallMaxSize.size.height);
    self.smallTextviewFrame = CGRectMake(LARGE_PLACEHOLDER_INSETS, 2 * SMALL_PLACEHOLDER_INSETS + smallMaxSize.size.height, insetedWidth, self.frame.size.height - 2 * SMALL_PLACEHOLDER_INSETS - smallMaxSize.size.height - COUNT_LABEL_OFFSET);
    
    self.placeholderLabel.frame = self.largePlaceholderFrame;
    self.charCountLabel.frame = CGRectMake(LARGE_PLACEHOLDER_INSETS, self.frame.size.height - COUNT_LABEL_OFFSET, insetedWidth, COUNT_LABEL_OFFSET);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.placeholderLargeColor.CGColor);
    CGContextSetLineWidth(context, 1.0f);
    float y = rect.size.height - COUNT_LABEL_OFFSET;
    CGContextMoveToPoint(context, LARGE_PLACEHOLDER_INSETS, y);
    CGContextAddLineToPoint(context, rect.size.width - LARGE_PLACEHOLDER_INSETS, y);
    CGContextStrokePath(context);
}

@end
