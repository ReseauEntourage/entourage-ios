//
//  OTTextView.m
//  entourage
//
//  Created by Ciprian Habuc on 11/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTextView.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"

#define MAX_LENGTH 150
#define CHARCOUNT_FRAME CGRectMake(15.0f, self.bounds.size.height - 19.0f, 200.0f, 15.0f)

#define PLACEHOLDER_LARGE_COLOR [UIColor appGreyishColor]
#define PLACEHOLDER_SMALL_COLOR [UIColor appOrangeColor]

#define PLACEHOLDER_LARGE_FONT [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
#define PLACEHOLDER_SMALL_FONT [UIFont systemFontOfSize: 9 weight:UIFontWeightLight];

#define CHARCOUNT_FONT [UIFont systemFontOfSize: 12 weight:UIFontWeightLight];

#define ANIMATION_DURATION 0.25f

@interface OTTextView() <UITextViewDelegate>

@property (nonatomic) BOOL isShowingCharCount;
@property (nonatomic, strong) UILabel *charCountLabel;

@end

@implementation OTTextView

/********************************************************************************/
#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    //self.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myTextBeginChange)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myTextDidChange)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myTextEndedChange)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
    
    
    
}

- (void)updateAfterSpeech {
    [self showSmallPlaceholder];
}

- (void)myTextBeginChange {
    [self showSmallPlaceholder];
    //NSLog (@"%d/%d", (int)self.text.length, MAX_LENGTH);
}
- (void)myTextDidChange {
    [self showSmallPlaceholder];
    //self.charCountLabel.text = [NSString stringWithFormat:@"%d/%d", (int)self.text.length, MAX_LENGTH];
}
- (void)myTextEndedChange {
    if (self.text.length == 0)
        [self showLargePlaceholder];
    //NSLog (@"%d/%d", (int)self.text.length, MAX_LENGTH);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.placeholderLabel = [[UILabel  alloc] initWithFrame:self.frame];
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.text = placeholder;
    self.placeholderLabel.font = PLACEHOLDER_LARGE_FONT;
    self.placeholderLabel.textColor = PLACEHOLDER_LARGE_COLOR;
    _placeholder = placeholder;
    [self addSubview:self.placeholderLabel];
}

- (void)showCharCount {
    self.isShowingCharCount = YES;
    
    self.charCountLabel = [[UILabel  alloc] initWithFrame:CHARCOUNT_FRAME];
    self.charCountLabel.text = [NSString stringWithFormat:@"0/%d", MAX_LENGTH];
    self.charCountLabel.font = CHARCOUNT_FONT;
    self.charCountLabel.textColor = PLACEHOLDER_LARGE_COLOR;
    
    [self addSubview:self.charCountLabel];
}

/********************************************************************************/
#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self showSmallPlaceholder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return text.length <= MAX_LENGTH;
}

//- (void)textViewDidChange:(UITextView *)textView {
//    //NSLog (@"%d/%d", (int)textView.text.length, MAX_LENGTH);
//}

- (void)showSmallPlaceholder {
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.placeholderLabel.textColor = PLACEHOLDER_SMALL_COLOR;
        self.placeholderLabel.frame = self.frame;
        self.placeholderLabel.font = PLACEHOLDER_SMALL_FONT;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showLargePlaceholder {
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.placeholderLabel.textColor = PLACEHOLDER_LARGE_COLOR;
        self.placeholderLabel.frame = self.frame;
        self.placeholderLabel.font = PLACEHOLDER_LARGE_FONT;
    } completion:^(BOOL finished) {
        
    }];
}

@end
