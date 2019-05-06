//
//  AuthenticationOverlayViewController.h
//  entourage
//
//  Created by Grégoire Clermont on 06/05/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AuthenticationOverlayDelegate <NSObject>

- (void)authenticationCanceled;

@end

@interface OTAuthenticationOverlayViewController : UIViewController

@property (nonatomic, weak) id<AuthenticationOverlayDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
