//
//  OTWelcomeViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 06/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTWelcomeViewController.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "UIView+entourage.h"

#define SHOW_LOGIN_SEGUE @"WelcomeLoginSegue"

@interface OTWelcomeViewController() <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@end

@implementation OTWelcomeViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
    [self addLoginBarButton];
    [self.startButton setupHalfRoundedCorners];
    [self setupWebView];
    
}

#pragma mark - Private

- (void)addLoginBarButton {
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:OTLocalizedString(@"doLogin")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(doLogin)];
    [loginButton setTintColor:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:loginButton];
}

- (void)setupWebView {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"html"];
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    // Tell the web view to load it
    [self.webView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
}

#pragma mark - IBActions

- (void)doLogin {
    [self performSegueWithIdentifier:SHOW_LOGIN_SEGUE sender:self];
}

#pragma mark - UIWebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    return YES;
}

@end
