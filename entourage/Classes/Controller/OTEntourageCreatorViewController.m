//
//  OTEntourageCreatorViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 10/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageCreatorViewController.h"
#import "UIViewController+menu.h"
#import "OTConsts.h"

@implementation OTEntourageCreatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString(@"Demande").uppercaseString;
    
    [self setupCloseModal];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Valider"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(sendEntourage)];
    [self.navigationItem setRightBarButtonItem:menuButton];

}

- (void)sendEntourage {
    
}


@end
