//
//  OTGeolocationRightsViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 13/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTGeolocationRightsViewController : UIViewController
@property (nonatomic, weak) IBOutlet UILabel *rightsTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightsDescLabel;
@property (nonatomic, weak) IBOutlet UIButton *continueButton;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIImageView *privacyIconImage;
@property (nonatomic) BOOL isShownOnStartup;
@end
