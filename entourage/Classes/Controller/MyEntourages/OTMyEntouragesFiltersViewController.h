//
//  OTMyEntouragesFiltersViewController.h
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTMyEntouragesFilterDelegate.h"

@interface OTMyEntouragesFiltersViewController : UIViewController

@property (nonatomic, weak) id<OTMyEntouragesFilterDelegate> filterDelegate;

@end
