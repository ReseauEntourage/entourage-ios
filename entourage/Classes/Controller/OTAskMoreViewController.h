//
//  OTAskMoreViewController.h
//  entourage
//
//  Created by Nicolas Telera on 08/12/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OTAskMoreViewControllerDelegate <NSObject>

- (void)hideBlurEffect;

@end

@interface OTAskMoreViewController : UIViewController

@property(nonatomic, weak) id<OTAskMoreViewControllerDelegate> delegate;

@end
