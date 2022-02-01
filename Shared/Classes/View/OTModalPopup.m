//
//  OTModalPopup.m
//  entourage
//
//  Created by Grégoire Clermont on 07/05/2019.
//  Copyright © 2019 Entourage. All rights reserved.
//

#import "OTModalPopup.h"

@interface OTModalPopup ()

@property (weak, nonatomic) IBOutlet UIView *bodyContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBodyInset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBodyInset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightBodyInset;

@end

@implementation OTModalPopup

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (!self) return nil;
    
    [self commonInit];
    
    return self;
}

- (void)commonInit {
    self.axis = UILayoutConstraintAxisVertical;
    
    UIView *template = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"OTModalPopup" owner:self options:nil] firstObject];
    
    template.frame = self.bounds;
    template.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:template atIndex:0];
        
    self.layoutMarginsRelativeArrangement = YES;
    if (@available(iOS 11.0, *)) {
        self.insetsLayoutMarginsFromSafeArea = NO;
    }
    self.layoutMargins =
        UIEdgeInsetsMake(self.bodyContainer.frame.origin.y,
                         self.leftBodyInset.constant,
                         self.bottomBodyInset.constant,
                         self.rightBodyInset.constant);
}

- (void)layoutSubviews {
    self.spacing = 28;
    if (@available(iOS 11.0, *)) {
        self.insetsLayoutMarginsFromSafeArea = NO;
    }
    [super layoutSubviews];
}

#pragma mark - UI Controls

- (IBAction)tappedClose {
    [self.delegate closeModal];
}

@end
