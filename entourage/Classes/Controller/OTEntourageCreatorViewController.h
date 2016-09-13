//
//  OTEntourageCreatorViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 10/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTEntourage.h"


@protocol EntourageCreatorDelegate <NSObject>

- (void)didCreateEntourage;

@end

@interface OTEntourageCreatorViewController : UIViewController

@property (nonatomic, weak) id<EntourageCreatorDelegate> entourageCreatorDelegate;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) CLLocation *location;

@end
