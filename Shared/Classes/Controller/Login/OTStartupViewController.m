//
//  OTStartupViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 20/01/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <SafariServices/SFSafariViewControllerConfiguration.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "OTStartupViewController.h"
#import "UIView+entourage.h"
#import "NSUserDefaults+OT.h"
#import "UINavigationController+entourage.h"
#import "OTAppConfiguration.h"
#import "OTAppState.h"
#import "OTSafariService.h"
#import "OTAuthService.h"
#import "entourage-Swift.h"

@interface OTStartupViewController () <UIScrollViewDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginlessButton;
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
    
    [self.loginlessButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
    
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.currentPageIndicatorTintColor = [ApplicationTheme shared].backgroundThemeColor;
    
    self.title = @"";
    
    [self setupScrollView];
    [self setupObservers];
}

-(void)setupObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResign:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

-(void)applicationWillResign:(NSNotification*)notification {
    // Human Interface Guidelines :
    // "Allow people to cancel alerts by exiting to the Home screen."
    // https://developer.apple.com/design/human-interface-guidelines/ios/views/alerts/
    [self dismissAlert];
}

-(void)dismissAlert {
    if ([self presentedViewController].class == UIAlertController.class) {
      [self dismissViewControllerAnimated:NO completion:nil];
    }
}

-(IBAction)showSignUp:(id)sender {
    [OTLogger logEvent:@"SplashSignUp"];
    [OTAppState continueFromStartupScreen:self creatingUser:YES];
}

-(IBAction)showLogin:(id)sender {
    [OTAppState continueFromStartupScreen:self creatingUser:NO];
}

#pragma mark - Loginless Alert

UIAlertController* loginlessAlert;
SFSafariViewController *loginlessSafariController;

-(void)initLoginlessAlert {
    if (loginlessAlert) return;
    
    loginlessAlert = [UIAlertController alertControllerWithTitle:@"Conditions d'utilisation"
                                                         message:@"Pour continuer, acceptez les CGU et la Politique de confidentialité d'Entourage"
                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [loginlessAlert addAction:[UIAlertAction actionWithTitle:@"Lire" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         NSURL *url = [OTSafariService redirectUrlWithIdentifier:@"terms"];
                                                         loginlessSafariController =
                                                            [OTSafariService newSafariControllerWithUrl:url
                                                                                entersReaderIfAvailable:YES];
                                                         loginlessSafariController.delegate = self;
                                                         [self presentViewController:loginlessSafariController animated:YES completion:nil];
                                                     }]];
    [loginlessAlert addAction:[UIAlertAction actionWithTitle:@"J'accepte" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [self authenticateAnonymousUser];
                                                     }]];
    
    loginlessAlert.preferredAction = loginlessAlert.actions.lastObject;
}

-(IBAction)showLoginlessAlert:(id)sender {
    [self showLoginlessAlert];
}

-(void)showLoginlessAlert {
    [self initLoginlessAlert];
    [self presentViewController:loginlessAlert animated:YES completion:nil];
    loginlessAlert = nil;
}

#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    if ([controller isEqual:loginlessSafariController]) {
        [self showLoginlessAlert];
        loginlessSafariController = nil;
    }
}

- (void)authenticateAnonymousUser {
    [SVProgressHUD show];

    [[OTAuthService new] anonymousAuthWithSuccess:^(OTUser *user) {
        [SVProgressHUD dismiss];

        [[NSUserDefaults standardUserDefaults] setCurrentUser:user];

        [OTAppState navigateToAuthenticatedLandingScreen];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"error")
                                                                       message:OTLocalizedString(@"generic_error")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction: [UIAlertAction actionWithTitle:OTLocalizedString(@"ok")
                                                   style:UIAlertActionStyleDefault
                                                 handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
};

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
