//
//  OTCloseKeyboardOnTapBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTCloseKeyboardOnTapBehavior.h"

@interface OTCloseKeyboardOnTapBehavior ()

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@end

@implementation OTCloseKeyboardOnTapBehavior

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.owner.view addGestureRecognizer:self.tapRecognizer];
}

- (void)tapped:(UITapGestureRecognizer *)recognizer {
    if([self.inputView isFirstResponder])
        [self.inputView resignFirstResponder];
    else
        recognizer.cancelsTouchesInView = NO;
}

@end
