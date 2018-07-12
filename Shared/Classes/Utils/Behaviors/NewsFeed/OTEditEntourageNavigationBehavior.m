//
//  OTEditEntourageNavigationBehavior.m
//  entourage
//
//  Created by sergiu.buceac on 18/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEditEntourageNavigationBehavior.h"
#import "OTLocationSelectorViewController.h"
#import "OTEditEntourageTableSource.h"
#import "OTEditEntourageTitleViewController.h"
#import "OTEditEntourageDescViewController.h"
#import "OTCategoryViewController.h"

@interface OTEditEntourageNavigationBehavior ()
<
    LocationSelectionDelegate,
    EditTitleDelegate,
    EditDescriptionDelegate,
    CategorySelectionDelegate
>

@property (nonatomic, strong) OTEntourage *entourage;

@end

@implementation OTEditEntourageNavigationBehavior

- (BOOL)prepareSegue:(UIStoryboardSegue *)segue {
    UIViewController *destinationViewController = segue.destinationViewController;
    [OTAppConfiguration configureNavigationControllerAppearance:destinationViewController.navigationController];
    
    if ([segue.identifier isEqualToString:@"CategoryEditSegue"]) {
        OTCategoryViewController* controller = (OTCategoryViewController *)destinationViewController;
        controller.categorySelectionDelegate = self;
        controller.selectedCategory = self.entourage.categoryObject;
        return YES;
    }
    if ([segue.identifier isEqualToString:@"EditLocation"]) {
        [OTLogger logEvent:@"ChangeLocationClick"];
        OTLocationSelectorViewController* controller = (OTLocationSelectorViewController *)destinationViewController;
        controller.locationSelectionDelegate = self;
        controller.selectedLocation = self.entourage.location;
        return YES;
    }
    if ([segue.identifier isEqualToString:@"TitleEditSegue"]) {
        OTEditEntourageTitleViewController* controller = (OTEditEntourageTitleViewController *)destinationViewController;
        controller.delegate = self;
        controller.currentTitle = self.entourage.title;
        controller.currentEntourage = self.entourage;
        return YES;
    }
    if ([segue.identifier isEqualToString:@"DescriptionEditSegue"]) {
        OTEditEntourageDescViewController* controller = (OTEditEntourageDescViewController *)destinationViewController;
        controller.delegate = self;
        controller.currentDescription = self.entourage.desc;
        controller.currentEntourage = self.entourage;
        return YES;
    }
    return NO;
}

- (void)editLocation:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"EditLocation" sender:self];
}

- (void)editTitle:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"TitleEditSegue" sender:self];
}

- (void)editDescription:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"DescriptionEditSegue" sender:self];
}

- (void)editCategory:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"CategoryEditSegue" sender:self];
}

#pragma mark - LocationSelectionDelegate

- (void)didSelectLocation:(CLLocation *)selectedLocation {
    self.entourage.location = selectedLocation;
    [self.editEntourageSource updateLocationTitle];
}

#pragma mark - EditTitleDelegate

- (void)titleEdited:(NSString *)title {
    self.entourage.title = title;
    [self.editEntourageSource updateTexts];
}

#pragma mark - EditDescriptionDelegate

- (void)descriptionEdited:(NSString *)description {
    self.entourage.desc = description;
    [self.editEntourageSource updateTexts];
}

#pragma mark - CategorySelectionDelegate

- (void)didSelectCategory:(OTCategory *)category {
    self.entourage.categoryObject = category;
    self.entourage.category = category.category;
    self.entourage.entourage_type = category.entourage_type;
    [self.editEntourageSource updateTexts];
}
    
- (void)selectDefaultCategory {
    OTCategory *defaultCategory = nil;
    [self didSelectCategory:defaultCategory];
        // EMA-2140
        // Select by default the category: "Partager un repas, un café":
        // "entourage_type": "contribution",
        // "display_category": "social",
//        if (!self.selectedCategory) {
//            [self selectCategoryAtIndex:[self indexPathForCategoryWithType:@"contribution" subcategory:@"social"]];
//        }
}

@end
