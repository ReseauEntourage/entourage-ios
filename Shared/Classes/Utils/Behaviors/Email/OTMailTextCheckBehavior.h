//
//  OTMailTextCheckBehavior.h
//  entourage
//
//  Created by sergiu buceac on 11/22/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"

@interface OTMailTextCheckBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;
@property (nonatomic, weak) IBOutlet UITextView *txtWithEmailLinks;

@end
