//
//  OTUserNameViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 08/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OTUserNameViewControllerDelegate <NSObject>

- (void)userNameDidChange;

@end

@interface OTUserNameViewController : UIViewController

@property (assign, nonatomic) id<OTUserNameViewControllerDelegate> delegate;

@end
