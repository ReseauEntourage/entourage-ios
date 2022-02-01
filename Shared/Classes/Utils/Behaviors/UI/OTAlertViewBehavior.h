//
//  OTAlertViewBehavior.h
//  entourage
//
//  Created by veronica.gliga on 07/03/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTBehavior.h"

@interface OTAlertViewBehavior : OTBehavior

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;

- (void)addAction:(NSString *)title handler:(void (^)(UIAlertAction*))handler;
- (void)presentOnViewController:(UIViewController*)viewController;

+ (void)setupOngoingCreateEntourageWithAction:(OTAlertViewBehavior *)action;

@end
