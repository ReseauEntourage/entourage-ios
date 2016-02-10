//
//  OTLostCodeViewController.h
//  entourage
//
//  Created by Nicolas Telera on 05/01/2016.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LostCodeDelegate <NSObject>

- (void)loginWithNewCode:(NSString*)code;

@end

@interface OTLostCodeViewController : UIViewController

@property(nonatomic, weak) id<LostCodeDelegate> codeDelegate;


@end
