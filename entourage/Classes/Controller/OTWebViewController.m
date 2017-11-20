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

#define DISTANCE_ABOVE_NAVIGATION_BAR 65

@interface OTWebViewController ()

@property (nonatomic, weak) IBOutlet UINavigationItem *navigationItem;

@end

@implementation OTWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:[self.urlString stringByRemovingPercentEncoding]];
    NSArray  *parts = [url.absoluteString componentsSeparatedByString:@"."];
    NSString *justDomain = [NSString stringWithFormat:@"%@.%@",
                            parts[parts.count - 2], parts[parts.count - 1]];
    self.navigationItem.title = justDomain;
    [self configureUIBarButtonItems];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:urlRequest];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(moveViewWithGestureRecognizer:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(tap:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
   
}

- (void)configureUIBarButtonItems {
    UIImage *menuImage = [[UIImage imageNamed:@"close.png"]
                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] init];
    [menuButton setImage:menuImage];
    [menuButton setTarget:self];
    [menuButton setAction:@selector(close)];
    [self.navigationItem setLeftBarButtonItem:menuButton];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

- (void)setRightBarButtonView:(NSMutableArray *)views
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 11)
    {
        [self.navigationItem setRightBarButtonItems:views];
    }
    else
    {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                               target:nil
                                                                               action:NULL];
        [space setWidth:-13];
        
        NSArray *items = @[space];
        
        [self.navigationItem setRightBarButtonItems:[items arrayByAddingObjectsFromArray:views]];
    }
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:^() {
        if ([self.webViewDelegate respondsToSelector:@selector(webview:)])
            [self.webViewDelegate performSelector:@selector(webview:) withObject:nil];
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
        [self share:self.urlString];
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

- (void)share:(NSString *)content {
    NSArray *objectsToShare = @[content];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare
                                                                             applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer{
    [UIView animateWithDuration:1.0 animations:^{
        CGPoint translation = [panGestureRecognizer translationInView:self.view];
        CGRect frame = self.view.frame;
        frame.origin.y = translation.y;
        self.view.frame = frame;
    }];
    if(panGestureRecognizer.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:1.0 animations:^{
            CGPoint translation = [panGestureRecognizer translationInView:self.view];
            if(translation.y >= self.view.bounds.size.height/2)
                [self close];
            else {
                CGRect frame = self.view.frame;
                frame.origin = CGPointMake(0, 0);
                self.view.frame = frame;
            }
        }];
    }
}

- (void)tap:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint touchPoint = [tapGestureRecognizer locationInView:self.view];
    if(touchPoint.y < DISTANCE_ABOVE_NAVIGATION_BAR)
        [self close];
}

@end
