//
//  OTEditEntourageDescViewController.h
//  entourage
//
//  Created by sergiu.buceac on 18/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTEntourage.h"

@protocol EditDescriptionDelegate <NSObject>

- (void)descriptionEdited:(NSString *)description;

@end

@interface OTEditEntourageDescViewController : UIViewController

@property (nonatomic, strong) NSString *currentDescription;
@property (nonatomic, strong) OTEntourage *currentEntourage;
@property (nonatomic, weak) id<EditDescriptionDelegate> delegate;

@end
