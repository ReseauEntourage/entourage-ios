//
//  OTNoDataBehavior.h
//  entourage
//
//  Created by sergiu buceac on 11/15/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"

@interface OTNoDataBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIView *noDataPopup;
@property (nonatomic, weak) IBOutlet UITextView *txtNoData;

- (IBAction)closePopup:(id)sender;
- (void)switchedToNewsfeeds;
- (void)switchedToGuide;
- (void)switchedToEvents;
- (void)showNoData;
- (void)hideNoData;

@end
