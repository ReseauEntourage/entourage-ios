//
//  OTMyEntouragesViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/9/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesViewController.h"
#import "OTCollectionSourceBehavior.h"
#import "OTCollectionViewDataSourceBehavior.h"
#import "OTEntourageService.h"
#import "SVProgressHUD.h"

@interface OTMyEntouragesViewController ()

@property (strong, nonatomic) IBOutlet OTCollectionSourceBehavior *dataSource;
@property (strong, nonatomic) IBOutlet OTCollectionViewDataSourceBehavior *collectionDataSource;


@end

@implementation OTMyEntouragesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionDataSource initialize];

    [self loadInvitations];
}

#pragma mark - private methods

- (void)loadInvitations {
    [SVProgressHUD show];
    [[OTEntourageService new] entourageGetInvitationsWithSuccess:^(NSArray *items) {
        [SVProgressHUD dismiss];
        [self.dataSource updateItems:items];
        [self.collectionDataSource refresh];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Error loading invitations."];
    }];
}

@end
