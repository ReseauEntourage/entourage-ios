//
//  OTMyEntouragesOptionsViewController.h
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTMyEntouragesOptionsDelegate.h"


@interface OTMyEntouragesOptionsViewController : UIViewController

@property (nonatomic, weak) id<OTMyEntouragesOptionsDelegate> delegate;

@end
