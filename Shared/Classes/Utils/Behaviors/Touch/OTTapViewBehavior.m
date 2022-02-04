//
//  OTTapViewBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTTapViewBehavior.h"

@interface OTTapViewBehavior ()

@property (nonatomic, strong) UITapGestureRecognizer *recognizer;

@end

@implementation OTTapViewBehavior

- (void)initialize {
    self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [self.tapView addGestureRecognizer:self.recognizer];
}

#pragma mark - private methods

- (void)tapped {
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
