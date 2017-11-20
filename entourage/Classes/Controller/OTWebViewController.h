//
//  OTWebViewController.h
//  entourage
//
//  Created by veronica.gliga on 15/11/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTAnnouncement.h"

@protocol OTWebViewDelegate <NSObject>

- (void)webview:(NSString *)url;

@end

@interface OTWebViewController : UIViewController

@property (nonatomic, weak) id<OTWebViewDelegate> webViewDelegate;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *urlString;

@end
