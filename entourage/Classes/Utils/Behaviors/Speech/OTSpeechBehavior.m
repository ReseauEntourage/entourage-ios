//
//  OTSpeechBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/18/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTSpeechBehavior.h"
#import "OTConsts.h"
#import "OTTextWithCount.h"

#define MAX_NUMBER_OF_VISIBLE_LINES 4

@interface OTSpeechBehavior ()

@property (nonatomic, assign) CGFloat originalHeight;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) BOOL firstResize;

@end

@implementation OTSpeechBehavior

- (void)initialize {
    self.firstResize = YES;
    if(!self.txtOutput.delegate)
        self.txtOutput.delegate = self;
    [super initialize];
}

- (NSString *)currentText {
    return self.txtOutput.text;
}

- (void)setCurrentText:(NSString *)currentText {
    self.txtOutput.text = currentText;
}

- (void)endEdit {
    [self.txtOutput resignFirstResponder];
    if(self.autoHeight)
        self.heightConstraint.constant = self.originalHeight;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [Flurry logEvent:@"WriteMessage"];
    if(self.autoHeight)
        [self recalculateInputHeight];
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
    [self updateRecordButton];
}

#pragma mark - private methods

- (void)recalculateInputHeight {
    if(self.firstResize) {
        [self fillOriginalSize];
        self.firstResize = NO;
    }
    
    CGRect boundingRect = [self.txtOutput.text boundingRectWithSize:CGSizeMake(self.txtOutput.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.txtOutput.font} context:nil];
    CGSize boundingSize = boundingRect.size;
    boundingSize.height = boundingSize.height + self.txtOutput.textContainerInset.top + self.txtOutput.textContainerInset.bottom;

    if(boundingSize.height < self.originalHeight)
        self.heightConstraint.constant = self.originalHeight;
    else if(boundingSize.height > self.maxHeight)
        self.heightConstraint.constant = self.maxHeight;
    else
        self.heightConstraint.constant = boundingSize.height;
}

- (void)fillOriginalSize {
    self.originalHeight = self.heightConstraint.constant;
    CGRect boundingRect = [@"a" boundingRectWithSize:CGSizeMake(self.txtOutput.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.txtOutput.font} context:nil];
    CGSize boundingSize = boundingRect.size;
    self.maxHeight = boundingSize.height * MAX_NUMBER_OF_VISIBLE_LINES + self.txtOutput.textContainerInset.top + self.txtOutput.textContainerInset.bottom;
}

@end
