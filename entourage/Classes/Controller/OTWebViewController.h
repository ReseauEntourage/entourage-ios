//
//  OTWebViewController.h
//  entourage
//
//  Created by veronica.gliga on 15/11/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTAnnouncement.h"

@interface OTWebViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *viewTitle;
@property (nonatomic, assign) BOOL shouldDisableClosingOnPangesture;
@property (nonatomic, assign) BOOL shouldHideCustomLoadingIndicator;
@property (nonatomic, assign) BOOL shouldHideCustomNavigationItem;

@end
