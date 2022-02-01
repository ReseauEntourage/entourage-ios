//
//  OTModalPopupViewController.m
//  entourage
//
//  Created by Grégoire Clermont on 13/05/2019.
//  Copyright © 2019 Entourage. All rights reserved.
//

#import "OTModalPopupViewController.h"

@interface OTModalPopupViewController () <OTModalPopupDelegate>

@property (weak, nonatomic) IBOutlet UIStackView *modalContainer;

@end

@implementation OTModalPopupViewController

#pragma mark - Overrides

// so that subclasses will also use this nib
- (instancetype)init {
    return [super initWithNibName:@"OTModalPopupViewController" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self installModal];
}

- (void)installModal {
    self.modal.delegate = self;
    [self.modalContainer addArrangedSubview:self.modal];
}

#pragma mark - Setters

- (void)setModal:(OTModalPopup *)modal {
    [self.modalContainer removeArrangedSubview:self.modal];
    _modal = modal;
    [self installModal];
}

#pragma mark - OTModalPopupDelegate

- (void)closeModal {
    [self dismiss];
}

#pragma mark - Gesture Recognizers

- (IBAction)tappedBackdrop {
    [self dismiss];
}

#pragma mark - Private Methods

- (void)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
