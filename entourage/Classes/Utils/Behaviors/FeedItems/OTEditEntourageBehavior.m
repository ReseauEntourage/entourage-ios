//
//  OTEditEntourageBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/31/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEditEntourageBehavior.h"
#import "OTEntourageEditorViewController.h"
#import "OTFeedItemFactory.h"
#import "OTConsts.h"
#import "OTCategoryFromJsonService.h"
#import "OTCategoryType.h"
#import "OTCategory.h"
#import "OTLocationManager.h"

@interface OTEditEntourageBehavior () <EntourageEditorDelegate>

@property (nonatomic, strong) OTEntourage *entourage;

@end

@implementation OTEditEntourageBehavior

- (void)doEdit:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"EntourageEditorSegue" sender:self];
}

- (BOOL)prepareSegue:(UIStoryboardSegue *)segue {
    if([segue.identifier isEqualToString:@"EntourageEditorSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTEntourageEditorViewController *controller = (OTEntourageEditorViewController *)navController.topViewController;
        [self setupCategory];
        controller.entourage = self.entourage;
        controller.entourageEditorDelegate = self;
    }
    else
        return NO;
    return YES;
}

- (void)setupCategory {
    NSArray *categorySource = [OTCategoryFromJsonService getData];
    OTCategoryType *categoryType;
    NSDictionary *categoryDict = [OTCategory createDictionary];
    if([self.entourage.entourage_type isEqualToString:@"contribution"]) {
         categoryType = categorySource[OTContribution];
    } else {
        categoryType = categorySource[OTAskForHelp];
    }
    NSNumber *indexNumber = [categoryDict valueForKey:self.entourage.category];
    self.entourage.categoryObject = categoryType.categories[indexNumber.intValue];
}

#pragma mark - EntourageEditorDelegate

- (void)didEditEntourage:(OTEntourage *)entourage {
    [[[OTFeedItemFactory createFor:self.entourage] getChangedHandler] updateWith:entourage];
    NSDictionary* notificationInfo = @{ kNotificationEntourageChangedEntourageKey: entourage };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEntourageChanged object:nil userInfo:notificationInfo];
    [self.owner dismissViewControllerAnimated:NO completion:nil];
}

@end
