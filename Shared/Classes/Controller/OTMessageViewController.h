//
//  OTMessageViewController.h
//  entourage
//
//  Created by Nicolas Telera on 16/12/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTMessageViewController : UIViewController

- (void)configureWithSender:(NSString *)sender
                  andObject:(NSString *)object
                 andMessage:(NSString *)message;

@end
