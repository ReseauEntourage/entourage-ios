//
//  OTDisclaimerViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 09/06/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDisclaimerViewController.h"
#import <WebKit/WebKit.h>
#import "UIViewController+menu.h"

@interface OTDisclaimerViewController ()

@end

@implementation OTDisclaimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *rejectDisclaimerButton =  [self setupCloseModal];
    [rejectDisclaimerButton setAction:@selector(doRejectDisclaimer)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doAcceptDisclaimer {
    
    if ([self.disclaimerDelegate respondsToSelector:@selector(disclaimerWasAccepted)])
        [self.disclaimerDelegate disclaimerWasAccepted];
}

- (void)doRejectDisclaimer {
    if ([self.disclaimerDelegate respondsToSelector:@selector(disclaimerWasRejected)])
        [self.disclaimerDelegate disclaimerWasRejected];

}

@end
