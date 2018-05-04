//
//  OTGeolocationDeniedViewController.h
//  entourage
//
//  Created by sergiu buceac on 10/4/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTGeolocationDeniedViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIButton *activateButton;
@property (nonatomic, weak) IBOutlet UIButton *ignoreButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;
@end
