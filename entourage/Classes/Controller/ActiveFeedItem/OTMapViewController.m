//
//  OTMapViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMapViewController.h"
#import "UIColor+entourage.h"
#import "OTFeedItemFactory.h"
#import "OTMapAnnotationProviderBehavior.h"
#import "OTStatusChangedBehavior.h"
#import "OTSummaryProviderBehavior.h"
#import "OTUserProfileBehavior.h"
#import "OTInviteBehavior.h"
#import "UIBarButtonItem+factory.h"
#import "OTMembersDataSource.h"
#import "OTTableDataSourceBehavior.h"
#import "OTEntourageEditorViewController.h"

@interface OTMapViewController ()

@property (strong, nonatomic) IBOutlet OTMapAnnotationProviderBehavior *annotationProvider;
@property (strong, nonatomic) IBOutlet OTStatusChangedBehavior *statusChangedBehavior;
@property (strong, nonatomic) IBOutlet OTSummaryProviderBehavior *summaryProviderBehavior;
@property (strong, nonatomic) IBOutlet OTUserProfileBehavior *userProfileBehavior;
@property (strong, nonatomic) IBOutlet OTInviteBehavior *inviteBehavior;
@property (strong, nonatomic) IBOutlet OTMembersDataSource *membersDataSource;
@property (strong, nonatomic) IBOutlet OTTableDataSourceBehavior *membersTableSource;

@end

@implementation OTMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.summaryProviderBehavior configureWith:self.feedItem];
    [self.annotationProvider configureWith:self.feedItem];
    [self.annotationProvider addStartPoint];
    [self.annotationProvider drawData];
    [self.statusChangedBehavior configureWith:self.feedItem];
    [self.inviteBehavior configureWith:self.feedItem];
    [self.membersTableSource initialize];

    self.title = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle].uppercaseString;
    [self setupToolbarButtons];
    [self.membersDataSource loadDataFor:self.feedItem];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

- (IBAction)showProfile {
    [self.userProfileBehavior showProfile:self.feedItem.author.uID];
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.inviteBehavior prepareSegueForInvite:segue])
        return;
    if([self.userProfileBehavior prepareSegueForUserProfile:segue])
        return;
    if([self.statusChangedBehavior prepareSegueForNextStatus:segue])
        return;
    if([segue.identifier isEqualToString:@"EntourageEditorSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTEntourageEditorViewController *controller = (OTEntourageEditorViewController *)navController.topViewController;
        controller.entourage = (OTEntourage *)self.feedItem;
    }
}

#pragma mark - private methods

- (void)setupToolbarButtons {
    id<OTStateInfoDelegate> stateInfo = [[OTFeedItemFactory createFor:self.feedItem] getStateInfo];
    if(![stateInfo canChangeEditState])
        return;
    NSMutableArray *rightButtons = [NSMutableArray new];
    UIBarButtonItem *optionsButton = [UIBarButtonItem createWithImageNamed:@"more" withTarget:self.statusChangedBehavior andAction:@selector(startChangeStatus)];
    [rightButtons addObject:optionsButton];
    if([stateInfo canInvite]) {
        UIBarButtonItem *plusButton = [UIBarButtonItem createWithImageNamed:@"userPlus" withTarget:self.inviteBehavior andAction:@selector(startInvite)];
        [rightButtons addObject:plusButton];
        [self.navigationItem setRightBarButtonItems:@[optionsButton, plusButton]];
    }
    if([stateInfo canEdit]) {
        UIBarButtonItem *editButton = [UIBarButtonItem createWithImageNamed:@"share" withTarget:self andAction:@selector(edit)];
        [rightButtons addObject:editButton];
    }
    [self.navigationItem setRightBarButtonItems:rightButtons];
}

- (void)edit {
    [self performSegueWithIdentifier:@"EntourageEditorSegue" sender:self];
}

@end
