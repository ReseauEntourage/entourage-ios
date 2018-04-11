//
//  OTWebViewController.m
//  entourage
//
//  Created by veronica.gliga on 15/11/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTWebViewController.h"
#import "OTBarButtonView.h"
#import "UIColor+entourage.h"
#import "UIViewController+menu.h"
#import "OTConsts.h"
#import "SVProgressHUD.h"
#import "OTActivityProvider.h"

#define DISTANCE_ABOVE_NAVIGATION_BAR 65

@interface OTWebViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UINavigationItem *customNavigationItem;
@property (nonatomic, weak) IBOutlet UIView *animatedView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *refreshItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *backItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *nextItem;
@property (nonatomic, weak) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic) IBOutlet NSLayoutConstraint *topNavigationItemConstraint;

@end

@implementation OTWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.shouldDisableClosingOnPangesture) {
        [self setupPanGesture];
    }
    
    if (!self.shouldHideCustomLoadingIndicator) {
        self.animatedView.layer.borderWidth = 14;
        CAShapeLayer * maskLayer = [CAShapeLayer layer];
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.view.bounds
                                               byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight
                                                     cornerRadii: (CGSize){14, 14}].CGPath;
        self.animatedView.layer.mask = maskLayer;
    }
    
    _webView.delegate = self;
    
    if (self.shouldHideCustomNavigationItem) {
        self.topNavigationItemConstraint.constant = 0;
        [self.webView setNeedsLayout];
        [self.webView layoutIfNeeded];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
    self.bottomToolbar.tintColor = [UIColor appOrangeColor];
    
    [self configureUIBarButtonItems];
    [self loadUrlWithString:self.urlString];
    
    if (self.viewTitle) {
        self.title = self.viewTitle;
    } else {
        NSURL *url = [NSURL URLWithString:self.urlString];
        [self updateTitle:url];
    }
}

- (UINavigationItem*)navigationItem {
    if (self.navigationController) {
        return self.navigationController.navigationItem;
    }
    
    return self.customNavigationItem;
}

- (void)setupPanGesture {

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(moveViewWithGestureRecognizer:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(tap:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    panGestureRecognizer.cancelsTouchesInView = NO;
}

- (void)showLoading {
    if (self.shouldHideCustomLoadingIndicator) {
        return;
    }
    
    [SVProgressHUD show];
}

- (void)hideLoading {
    if (self.shouldHideCustomLoadingIndicator) {
        return;
    }
    
    [SVProgressHUD dismiss];
}

- (void)updateTitle:(NSURL*)url {
    self.urlString = url.absoluteString;
    
    NSString *host = url.host;
    if ([url.host hasPrefix:@"www"])
        host = [url.host substringFromIndex:4];
    NSString *domain = [NSString stringWithFormat:@"%@%@",[[host substringToIndex:1] uppercaseString],[host substringFromIndex:1]];
    
    self.navigationItem.title = domain;
}

- (void)updateBottomToolbarItems
{
    self.backItem.enabled = self.webView.canGoBack;
    self.nextItem.enabled = self.webView.canGoForward;
    self.refreshItem.enabled = !self.webView.isLoading;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    if (!self.viewTitle) {
        [self updateTitle:[self.webView.request mainDocumentURL]];
    }
    
    [self hideLoading];
    [self updateBottomToolbarItems];
}

- (IBAction)navigateNext {
    [self.webView goForward];
}

- (IBAction)navigateBack {
    [self.webView goBack];
}

- (IBAction)reload {
    [self.webView reload];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self showLoading];
    return YES;
}

- (void)configureUIBarButtonItems {
    UIImage *backImage = [[UIImage imageNamed:@"back.png"]
                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    [backButton setImage:backImage];
    [backButton setTarget:self];
    [backButton setAction:@selector(closeWebview)];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    NSMutableArray *rightButtons = [NSMutableArray new];
    UIButton *more = [UIButton buttonWithType:UIButtonTypeCustom];
    [more setImage:[UIImage imageNamed:@"more"]
          forState:UIControlStateNormal];
    [more addTarget:self
             action:@selector(showOptions)
    forControlEvents:UIControlEventTouchUpInside];
    [more setFrame:CGRectMake(0, 0, 30, 30)];
    
    OTBarButtonView *moreBarBtnView = [[OTBarButtonView alloc] initWithFrame:more.frame];
    [moreBarBtnView setPosition:BarButtonViewPositionRight];
    [moreBarBtnView addSubview:more];
    
    UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithCustomView:moreBarBtnView];
    [rightButtons addObject:optionsButton];
    
    [self setRightBarButtonView:rightButtons];
}

- (void)setRightBarButtonView:(NSMutableArray *)views
{
    BOOL isIOSVersion11 = [[[UIDevice currentDevice] systemVersion] doubleValue] >= 11;
    CGFloat spaceOffset = -13;
    
    if (isIOSVersion11) {
        [self.navigationItem setRightBarButtonItems:views];
    }
    else {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                               target:nil
                                                                               action:NULL];
        [space setWidth:spaceOffset];
        NSArray *items = @[space];
        NSArray *moreItems = [items arrayByAddingObjectsFromArray:views];
        
        [self.navigationItem setRightBarButtonItems:moreItems];
    }
}

- (void)closeWebview {
//    if (self.webView.canGoBack) {
//        [self.webView goBack];
//    }
//    else {
//        [self dismissViewControllerAnimated:YES completion:^() {
//            [self hideLoading];
//
//            if ([self.webViewDelegate respondsToSelector:@selector(didLoadUrlWithPath:)]) {
//                [self.webViewDelegate performSelector:@selector(webview:) withObject:nil];
//            }
//        }];
//    }
    [self dismissViewControllerAnimated:YES completion:^() {
        [self hideLoading];
    }];
}

- (void)showOptions {
    UIAlertAction *openInBorwser = [UIAlertAction actionWithTitle:OTLocalizedString(@"open_in_browser")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlString]];
    }];
    UIAlertAction *copyLink = [UIAlertAction actionWithTitle:OTLocalizedString(@"copy_link")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.urlString;
    }];
    UIAlertAction *share = [UIAlertAction actionWithTitle:OTLocalizedString(@"share")
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action)
    {
        [self share];
    }];
    
    [self displayAlertWithActions:@[openInBorwser, copyLink, share]];
}

- (void)displayAlertWithActions:(NSArray<UIAlertAction*> *)actions {
    UIAlertController *alert = [[UIAlertController alloc] init];
    for(UIAlertAction *action in actions)
        [alert addAction:action];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"closeAlert")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:NO completion:nil];
}

- (void)share {
    NSURL *url = [NSURL URLWithString:self.urlString];
    OTActivityProvider *activity = [[OTActivityProvider alloc] initWithPlaceholderItem:@{@"body":OTLocalizedString(@"share_webview"), @"url": url}];
    activity.emailBody = [NSString stringWithFormat:OTLocalizedString(@"share_webview"), url];
    activity.emailSubject = @"";
    activity.url = url;
    NSArray *objectsToShare = @[activity];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare
                                                                             applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer{
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint velocity = [panGestureRecognizer velocityInView:self.animatedView];
        CGPoint translation = [panGestureRecognizer translationInView:self.animatedView];
        CGFloat finalY = translation.y + 0.2*velocity.y;
        if(translation.y > 0) {
            if (finalY < DISTANCE_ABOVE_NAVIGATION_BAR) {
                finalY = DISTANCE_ABOVE_NAVIGATION_BAR;
            } else if (finalY > self.view.frame.size.height) {
                finalY = self.view.frame.size.height;
            }
            CGRect frame = self.animatedView.frame;
            frame.origin.y = finalY;
            self.animatedView.frame = frame;
        }
    }];
    if(panGestureRecognizer.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.5 animations:^{
            CGPoint translation = [panGestureRecognizer translationInView:self.animatedView];
            if(translation.y >= self.view.bounds.size.height/2)
                [self closeWebview];
            else {
                CGRect frame = self.animatedView.frame;
                frame.origin = CGPointMake(0, DISTANCE_ABOVE_NAVIGATION_BAR);
                self.animatedView.frame = frame;
            }
        }];
    }
}

- (void)tap:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint touchPoint = [tapGestureRecognizer locationInView:self.view];
    if(touchPoint.y < DISTANCE_ABOVE_NAVIGATION_BAR) {
        [self closeWebview];
    }
}

#pragma mark - Public

- (void)loadUrlWithString:(NSString*)path {
    NSURL *url = [NSURL URLWithString: path];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    [_webView loadRequest:urlRequest];
    [self updateBottomToolbarItems];
}
@end
