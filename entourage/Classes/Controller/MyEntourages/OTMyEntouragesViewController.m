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
#import "OTMoveUpOnViewHiddenBehavior.h"
#import "OTMyEntouragesDataSource.h"
#import "OTTableDataSourceBehavior.h"
#import "OTEntourageService.h"
#import "SVProgressHUD.h"

@interface OTMyEntouragesViewController ()

@property (strong, nonatomic) IBOutlet OTCollectionSourceBehavior *invitationsDataSource;
@property (strong, nonatomic) IBOutlet OTCollectionViewDataSourceBehavior *invitationsCollectionDataSource;
@property (strong, nonatomic) IBOutlet OTMoveUpOnViewHiddenBehavior *toggleCollectionView;
@property (strong, nonatomic) IBOutlet OTMyEntouragesDataSource *entouragesDataSource;
@property (strong, nonatomic) IBOutlet OTTableDataSourceBehavior *entouragesTableDataSource;

@end

@implementation OTMyEntouragesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.invitationsCollectionDataSource initialize];
    [self.entouragesTableDataSource initialize];
    [self.toggleCollectionView initialize];
    
    [self.toggleCollectionView toggle:NO animated:NO];
    
    [self loadInvitations];
    [self.entouragesDataSource loadData];
}

#pragma mark - private methods

- (void)loadInvitations {
    [[OTEntourageService new] entourageGetInvitationsWithSuccess:^(NSArray *items) {
        [self.toggleCollectionView toggle:[items count] > 0 animated:YES];
        [self.invitationsDataSource updateItems:items];
        [self.invitationsCollectionDataSource refresh];
    } failure:nil];
}

@end
