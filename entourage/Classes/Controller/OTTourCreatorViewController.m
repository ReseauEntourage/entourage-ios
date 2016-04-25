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

@property (nonatomic, weak) IBOutlet UIButton *feetButton;
@property (nonatomic, weak) IBOutlet UIButton *carButton;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *typeButtons;
@property (nonatomic, strong) NSString *currentTourType;


@end


@implementation OTTourCreatorViewController
#pragma mark - Private

#pragma mark - Utils

- (NSString *)selectedVehiculeType {
    if (self.feetButton.selected) {
        return OTLocalizedString(@"tour_vehicle_feet");
    }
    else if (self.carButton.selected) {
        return OTLocalizedString(@"tour_vehicle_car");
    }
    return nil;
}

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

- (IBAction)feetButtonDidTap:(id)sender {
    [self.feetButton setSelected:YES];
    [self.carButton setSelected:NO];
}

- (IBAction)carButtonDidTap:(id)sender {
    [self.carButton setSelected:YES];
    [self.feetButton setSelected:NO];
}

- (IBAction)typeButtonDidTap:(UIView *)sender {
    for (UIButton *button in self.typeButtons) {
        button.selected = (button == sender);
    }
}

- (IBAction)createTour:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
    NSString *tourType = [self selectedTourType];
    NSString *tourVehicle = [self selectedVehiculeType];
    //NSLog(@"about to create %@ tour on %@", tourType, tourVehicle);
    if ([self.tourCreatorDelegate respondsToSelector:@selector(createTour:withVehicle:)]) {
        [self.tourCreatorDelegate createTour:tourType withVehicle:tourVehicle];
    }
}


- (IBAction)dismissTourCreatpr:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
