//
//  OTUserEditPasswordViewController.h
//  entourage
//
//  Created by Mihai Ionescu on 08/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OTUserEditPasswordProtocol <NSObject>

- (void)setNewPassword:(NSString *)password;

@end

@interface OTUserEditPasswordViewController : UIViewController

@property (nonatomic, weak) id<OTUserEditPasswordProtocol> delegate;

@end
