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
#import "entourage-Swift.h"

@interface OTEditEntourageBehavior () <EntourageEditorDelegate>

@property (nonatomic, strong) OTEntourage *entourage;

@end

@implementation OTEditEntourageBehavior

- (void)doEdit:(OTEntourage *)entourage {
    self.entourage = entourage;
    [OTAppState continueEditingEntourage:entourage fromController:self.owner];
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
    OTCategoryType *categoryType = nil;
    NSDictionary *categoryDict = [OTCategory createDictionary];
    if ([self.entourage.entourage_type isEqualToString:@"contribution"]) {
        for (OTCategoryType *type in categorySource)
            if ([type.type isEqualToString:@"contribution"])
                categoryType = type;
    } else {
        for(OTCategoryType *type in categorySource)
            if ([type.type isEqualToString:@"ask_for_help"])
                categoryType = type;
    }
    
    if (categoryType) {
        NSNumber *indexNumber = [categoryDict valueForKey:self.entourage.category];
        if (indexNumber.intValue < categoryType.categories.count) {
            self.entourage.categoryObject = categoryType.categories[indexNumber.intValue];
        } else {
            // it means we are editing an outing
            self.entourage.categoryObject = [OTCategoryFromJsonService sampleEntourageEventCategory];
        }
    }
}

#pragma mark - EntourageEditorDelegate

- (void)didEditEntourage:(OTEntourage *)entourage {
    [self.owner dismissViewControllerAnimated:YES completion:^{
        [[[OTFeedItemFactory createFor:self.entourage] getChangedHandler] updateWith:entourage];
        NSDictionary* notificationInfo = @{ kNotificationEntourageChangedEntourageKey: entourage };
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEntourageChanged object:nil userInfo:notificationInfo];
    }];
}

@end
