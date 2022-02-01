//
//  OTAddActionFirstConsentViewController.h
//  entourage
//
//  Created by Smart Care on 05/10/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, OTAddActionConsentAnswerType) {
    OTAddActionConsentAnswerTypeAddForOtherPerson,
    OTAddActionConsentAnswerTypeAddForMe,
    OTAddActionConsentAnswerTypeAddForOtherOrganisation,
    OTAddActionConsentAnswerTypeAcceptActionDistribution,
    OTAddActionConsentAnswerTypeRejectActionDistribution,
    OTAddActionConsentAnswerTypeRequestModeration,
};

typedef void(^OTAddActionConsentCompletionBlock)(OTAddActionConsentAnswerType answer);

@interface OTAddActionFirstConsentViewController : UIViewController
@property (nonatomic, copy) OTAddActionConsentCompletionBlock completionBlock;
@end
