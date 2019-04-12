//
//  OTStartupViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 20/01/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTStartupViewController.h"
#import "UIView+entourage.h"
#import "NSUserDefaults+OT.h"
#import "UINavigationController+entourage.h"
#import "OTAppConfiguration.h"
#import "OTAppState.h"
#import "entourage-Swift.h"

@interface OTStartupViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic) NSMutableDictionary *pagesDict;
@property (nonatomic) NSMutableArray *pages;

@end

@implementation OTStartupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pages = @[].mutableCopy;
    self.pagesDict = @{}.mutableCopy;
    
    [self.navigationController presentTransparentNavigationBar];
    
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton setBackgroundColor:[ApplicationTheme shared].backgroundThemeColor];
    self.loginButton.layer.borderColor = [ApplicationTheme shared].backgroundThemeColor.CGColor;
    self.loginButton.layer.borderWidth = 1.5f;
    
    [self.registerButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
    self.registerButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.registerButton.layer.borderWidth = 1.5f;
    
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.currentPageIndicatorTintColor = [ApplicationTheme shared].backgroundThemeColor;
    
    self.title = @"";
    
    [self setupScrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController hideTransparentNavigationBar];
    
    [OTLogger logEvent:@"Screen01SplashView"];
    [NSUserDefaults standardUserDefaults].temporaryUser = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController presentTransparentNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
}

-(IBAction)showSignUp:(id)sender {
    [OTLogger logEvent:@"SplashSignUp"];
    [self performSegueWithIdentifier:@"SignUpSegue" sender:nil];
}

-(IBAction)showLogin:(id)sender {
    [OTAppState continueFromStartupScreen];
}

- (void)setupScrollView {
    self.scrollView.delegate = self;
    
    UIView *page1 = (UIView*)[[[NSBundle mainBundle] loadNibNamed:@"IntroPage1" owner:nil options:nil] firstObject];
    page1.backgroundColor = [UIColor clearColor];
    page1.translatesAutoresizingMaskIntoConstraints = NO;
    page1.clipsToBounds = YES;
    [self.scrollView addSubview:page1];
    [self.pages addObject:page1];
    
    UIView *page2 = (UIView*)[[[NSBundle mainBundle] loadNibNamed:@"IntroPage2" owner:nil options:nil] firstObject];
    page2.translatesAutoresizingMaskIntoConstraints = NO;
    page2.backgroundColor = [UIColor clearColor];
    page2.clipsToBounds = YES;
    [self.scrollView addSubview:page2];
    [self.pages addObject:page2];
    
    UIView *page3 = (UIView*)[[[NSBundle mainBundle] loadNibNamed:@"IntroPage3" owner:nil options:nil] firstObject];
    page3.translatesAutoresizingMaskIntoConstraints = NO;
    page3.backgroundColor = [UIColor clearColor];
    page3.clipsToBounds = YES;
    [self.scrollView addSubview:page3];
    [self.pages addObject:page3];
    
    UIView *page4 = (UIView*)[[[NSBundle mainBundle] loadNibNamed:@"IntroPage4" owner:nil options:nil] firstObject];
    page4.translatesAutoresizingMaskIntoConstraints = NO;
    page4.backgroundColor = [UIColor clearColor];
    page4.clipsToBounds = YES;
    [self.scrollView addSubview:page4];
    [self.pages addObject:page4];
    
    [self.pagesDict setObject:self.scrollView forKey:@"parent"];
    [self layoutPages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.pageControl.currentPage = index;
}

- (void)layoutPages {
    NSMutableString *horizontalString = [NSMutableString string];
    // Keep the start of the horizontal constraint
    [horizontalString appendString:@"H:|"];
    for (int i=0; i<self.pages.count; i++) {
        // Here I am providing the index of the array as the view name key in the dictionary
        [self.pagesDict setObject:self.pages[i] forKey:[NSString stringWithFormat:@"v%d",i]];
        // Since we are having only one view vertically, then we need to add the constraint now itself. Since we need to have fullscreen, we are giving height equal to the superview.
        NSString *verticalString = [NSString stringWithFormat:@"V:|-(-20)-[%@(==parent)]|", [NSString stringWithFormat:@"v%d",i]];
        // add the constraint
        [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalString options:0 metrics:nil views:self.pagesDict]];
        // Since we need to horizontally arrange, we construct a string, with all the views in array looped and here also we have fullwidth of superview.
        [horizontalString appendString:[NSString stringWithFormat:@"[%@(==parent)]", [NSString stringWithFormat:@"v%d",i]]];
    }
    // Close the string with the parent
    [horizontalString appendString:@"|"];
    // apply the constraint
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalString options:0 metrics:nil views:self.pagesDict]];
}

@end
