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
@property (weak, nonatomic) IBOutlet UIButton *betaButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation OTStartupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
//    self.betaButton.hidden = NO;
//    
//    NSString *title = [NSString stringWithFormat:@"Vous êtes sur %@.\n(Tapez pour changer)", [[OTAppConfiguration sharedInstance] environmentConfiguration].environmentName];
//    self.betaButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.betaButton.titleLabel.numberOfLines = 2;
//    [self.betaButton setTitle:title forState:UIControlStateNormal];
//    self.betaButton.hidden = YES;
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
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(4*width, height - 84);
    self.scrollView.delegate = self;
    
    UIView *page1 = (UIView*)[[[NSBundle mainBundle] loadNibNamed:@"IntroPage1" owner:nil options:nil] firstObject];
    page1.frame = CGRectMake(0, 0, width, height);
    page1.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:page1];
    
    UIView *page2 = (UIView*)[[[NSBundle mainBundle] loadNibNamed:@"IntroPage2" owner:nil options:nil] firstObject];
    page2.frame = CGRectMake(width, 0, width, height);
    page2.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:page2];
    
    UIView *page3 = (UIView*)[[[NSBundle mainBundle] loadNibNamed:@"IntroPage3" owner:nil options:nil] firstObject];
    page3.frame = CGRectMake(2*width, 0, width, height);
    page3.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:page3];
    
    UIView *page4 = (UIView*)[[[NSBundle mainBundle] loadNibNamed:@"IntroPage4" owner:nil options:nil] firstObject];
    page4.frame = CGRectMake(3*width, 0, width, height);
    page4.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:page4];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.pageControl.currentPage = index;
}

@end
