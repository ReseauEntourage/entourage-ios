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

@implementation OTSpeechBehavior

- (void)initialize {
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
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [Flurry logEvent:@"WriteMessage"];
    [self updateRecordButton];
}

@end
