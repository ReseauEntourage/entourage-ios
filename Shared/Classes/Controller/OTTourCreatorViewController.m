//
//  OTTourCreatorViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 25/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourCreatorViewController.h"
#import "OTConsts.h"
#import "OTTour.h"

@interface OTTourCreatorViewController ()

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *typeButtons;
@property (nonatomic, strong) NSString *currentTourType;
@property (nonatomic, strong) IBOutlet UIView *contentView;

@end

@implementation OTTourCreatorViewController
#pragma mark - Private

#pragma mark - Utils

- (NSString *)selectedTourType {
    NSInteger selectedType = 0;
    for (UIButton *button in self.typeButtons) {
        if (button.selected) {
            selectedType = button.tag;
        }
    }
    switch (selectedType) {
        case OTTypesBareHands:
            self.currentTourType = OTLocalizedString(@"tour_type_bare_hands");
            break;
        case OTTypesMedical:
            self.currentTourType = OTLocalizedString(@"tour_type_medical");
            break;
        case OTTypesAlimentary:
            self.currentTourType = OTLocalizedString(@"tour_type_alimentary");
            break;
    }
    return self.currentTourType;
}


#pragma mark - IBActions

- (IBAction)typeButtonDidTap:(UIView *)sender {
    for (UIButton *button in self.typeButtons) {
        button.selected = (button == sender);
        if(button.selected) {
            NSInteger selectedType = button.tag;
            NSString *message = @"";
            switch (selectedType) {
                case OTTypesBareHands:
                    message = @"SocialTourChoose";
                    break;
                case OTTypesMedical:
                    message = @"MedicalTourChoose";
                    break;
                case OTTypesAlimentary:
                    message = @"DistributionTourChoose";
                    break;
            }
            [OTLogger logEvent:message];
        }
    }
}

- (IBAction)createTour:(id)sender {
    [OTLogger logEvent:@"StartTourClick"];
    NSString *tourType = [self selectedTourType];
    if ([self.tourCreatorDelegate respondsToSelector:@selector(createTour:)]) {
        [self.tourCreatorDelegate createTour:tourType];
    }
}

- (IBAction)dismissTourCreatpr:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)viewDidTap:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.view];
    if(point.y < self.contentView.frame.origin.y)
        [self dismissViewControllerAnimated:YES completion:nil];
}

@end
