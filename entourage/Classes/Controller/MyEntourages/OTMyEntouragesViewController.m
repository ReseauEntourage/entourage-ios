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
#import "OTEntourageService.h"
#import "SVProgressHUD.h"

@interface OTMyEntouragesViewController ()

@property (strong, nonatomic) IBOutlet OTCollectionSourceBehavior *dataSource;
@property (strong, nonatomic) IBOutlet OTCollectionViewDataSourceBehavior *collectionDataSource;
@property (strong, nonatomic) IBOutlet OTMoveUpOnViewHiddenBehavior *toggleCollectionView;

@end

@implementation OTMyEntouragesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionDataSource initialize];
    [self.toggleCollectionView initialize];
    
    [self.toggleCollectionView toggle:NO animated:NO];
    
    [self loadInvitations];
}

#pragma mark - private methods

- (void)loadInvitations {
    [[OTEntourageService new] entourageGetInvitationsWithSuccess:^(NSArray *items) {
        [self.toggleCollectionView toggle:[items count] > 0 animated:YES];
        [self.dataSource updateItems:items];
        [self.collectionDataSource refresh];
    } failure:nil];
}

@end
