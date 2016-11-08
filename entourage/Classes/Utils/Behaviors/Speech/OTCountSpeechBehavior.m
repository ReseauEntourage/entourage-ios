//
//  OTCountSpeechBehavior.m
//  entourage
//
//  Created by sergiu buceac on 10/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTCountSpeechBehavior.h"

@implementation OTCountSpeechBehavior

- (NSString *)currentText {
    return self.txtOutput.textView.text;
}

- (void)setCurrentText:(NSString *)currentText {
    self.txtOutput.textView.text = currentText;
}

- (void)endEdit {
    [self.txtOutput.textView resignFirstResponder];
}

- (void)updateAfterSpeech {
    [self.txtOutput updateAfterSpeech];
}

@end
