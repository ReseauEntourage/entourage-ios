//
//  OTDisclaimerBaseBehavior.h
//  entourage
//
//  Created by sergiu buceac on 9/5/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"

@interface OTDisclaimerBaseBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (void)showDisclaimer;
- (void)showCreateEventDisclaimer;
- (BOOL)prepareSegue:(UIStoryboardSegue *)segue;
- (NSAttributedString *)disclaimerText;
- (NSAttributedString *)buildDisclaimerWithLink:(NSString *)originalString;

@end
