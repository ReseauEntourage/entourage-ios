//
//  OTFiltersViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 20/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OTFiltersViewControllerDelegate <NSObject>

- (void)filterChanged;

@end

@interface OTFiltersViewController : UIViewController

@property (nonatomic) BOOL isOngoingTour;
@property (nonatomic, weak) id<OTFiltersViewControllerDelegate> delegate;

@end
