//
//  OTCloseKeyboardOnTapBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"

@interface OTCloseKeyboardOnTapBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;
@property (nonatomic, weak) IBOutlet UIView *inputView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *inputViews;

@end
