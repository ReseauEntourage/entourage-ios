//
//  OTTutorialViewController.m
//  entourage
//
//  Created by sergiu buceac on 2/17/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTTutorialViewController.h"
#import "UIColor+entourage.h"

@interface OTTutorialViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) NSArray *tutorialControllers;

@end

#define PAGE_CONTROL_BOTTOM_OFFSET 97

@implementation OTTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tutorialControllers = [NSArray arrayWithObjects:
        [self instantiateTutorial:@"Tutorial1"],
        [self instantiateTutorial:@"Tutorial2"],
        [self instantiateTutorial:@"Tutorial3"],
        [self instantiateTutorial:@"Tutorial4"], nil
    ];
    [self setViewControllers:@[[self.tutorialControllers objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.dataSource = self;
    self.delegate = self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self configurePageControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self.tutorialControllers indexOfObject:viewController];
    if(index == 0 || index == NSNotFound)
        return nil;
    index--;
    return [self.tutorialControllers objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self.tutorialControllers indexOfObject:viewController];
    if(index == NSNotFound)
        return nil;
    index++;
    if(index == self.tutorialControllers.count)
        return nil;
    return [self.tutorialControllers objectAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return self.tutorialControllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

#pragma mark - private members

- (UIViewController *)instantiateTutorial:(NSString *)identifier {
    UIStoryboard *tutorialStoryboard = [UIStoryboard storyboardWithName:@"Tutorial" bundle:nil];
    return [tutorialStoryboard instantiateViewControllerWithIdentifier:identifier];
}

- (void)configurePageControl {
    for(UIView *view in self.view.subviews) {
        if([view isKindOfClass:[UIPageControl class]]) {
            ((UIPageControl*) view).currentPageIndicatorTintColor = [UIColor appOrangeColor];
            for(UIView *subview in view.subviews) {
                subview.layer.borderColor = [UIColor appGreyishBrownColor].CGColor;
                subview.layer.borderWidth = 0.5;
            }
            break;
        }
    }
}

@end
