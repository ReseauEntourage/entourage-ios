//
//  OTSpeechBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/18/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTSpeechBehaviorBase.h"

@interface OTSpeechBehavior : OTSpeechBehaviorBase <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *txtOutput;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;
@property (nonatomic, assign) BOOL autoHeight;

@end
