//
//  OTDisclaimerViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 09/06/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DisclaimerDelegate <NSObject>

- (void)disclaimerWasAccepted;
- (void)disclaimerWasRejected;

@end

@interface OTDisclaimerViewController : UIViewController

@property (nonatomic, weak) id<DisclaimerDelegate> disclaimerDelegate;
@property (nonatomic, strong) NSAttributedString *disclaimerText;

@end
