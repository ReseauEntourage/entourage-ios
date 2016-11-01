//
//  OTCountSpeechBehavior.h
//  entourage
//
//  Created by sergiu buceac on 10/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTSpeechBehaviorBase.h"
#import "OTTextWithCount.h"

@interface OTCountSpeechBehavior : OTSpeechBehaviorBase

@property (nonatomic, weak) IBOutlet OTTextWithCount *txtOutput;

@end
