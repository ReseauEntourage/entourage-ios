//
//  OTAddActionConfidentialityViewController.h
//  entourage
//
//  Created by Smart Care on 11/10/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OTAddActionConfidentialityConsentCompletionBlock)(BOOL requiresValidation);

@interface OTAddActionConfidentialityViewController : UIViewController
@property (nonatomic, copy) OTAddActionConfidentialityConsentCompletionBlock completionBlock;
@end
