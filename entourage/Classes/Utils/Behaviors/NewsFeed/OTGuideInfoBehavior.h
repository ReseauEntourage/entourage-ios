//
//  OTGuideInfoBehavior.h
//  entourage
//
//  Created by sergiu.buceac on 19/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"

@interface OTGuideInfoBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIView *infoPopup;

- (IBAction)closePopup:(id)sender;

@end
