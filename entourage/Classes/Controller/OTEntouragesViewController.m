//
//  OTEntouragesViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 26/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

// Controllers
#import "OTEntouragesViewController.h"
#import "OTFeedItemsTableView.h"
#import "OTFeedItemViewController.h"
#import "OTQuitFeedItemViewController.h"
#import "OTConfirmationViewController.h"
#import "OTMainViewController.h"

#import "OTConsts.h"

// Services
#import "OTFeedsService.h"
#import "OTTourService.h"
#import "OTUser.h"
#import "OTTour.h"
#import "OTFeedItem.h"
#import "OTEncounter.h"

// Helpers
#import "NSUserDefaults+OT.h"
#import "UIViewController+menu.h"
#import "UIColor+entourage.h"
#import "SVProgressHUD.h"

#define TOURS_PER_PAGE 10

typedef NS_ENUM(NSInteger){
    EntourageStatusActive,
    EntourageStatusClosed
} EntourageStatus;

/**************************************************************************************************/
#pragma mark - OTToursPagination

@interface OTToursPagination : NSObject

@property (nonatomic) NSInteger page;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSMutableArray *tours;

@end

@implementation OTToursPagination

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.page = 1;
        self.tours = [NSMutableArray new];
        self.isLoading = NO;
    }
    return self;
}

- (void)addTours:(NSArray*)tours
{
    self.isLoading = NO;
    if (tours != nil && tours.count > 0) {
        self.page++;
        [self.tours addObjectsFromArray:tours];
    }
}

@end

/**************************************************************************************************/
#pragma mark - OTEntouragesViewController

@interface OTEntouragesViewController() <OTFeedItemsTableViewDelegate, OTConfirmationViewControllerDelegate>

// UI
@property (nonatomic, weak) IBOutlet UISegmentedControl *statusSC;
@property (nonatomic, weak) IBOutlet OTFeedItemsTableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSTimer *refreshTimer;

// Pagination
@property (nonatomic, strong) OTToursPagination *activeToursPagination;
@property (nonatomic, strong) OTToursPagination *closedToursPagination;

@end


@implementation OTEntouragesViewController

/**************************************************************************************************/
#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString(@"myEntouragesTitle").uppercaseString;
    [self setupCloseModal];
    
    [self setupPagination];
    [self configureTableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.statusSC setSelectedSegmentIndex:EntourageStatusClosed];
    [self changedSegmentedControlSelection:self.statusSC];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:DATA_REFRESH_RATE target:self selector:@selector(getData) userInfo:nil repeats:YES];
    [self.refreshTimer fire];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.refreshTimer invalidate];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //if ([segue.identifier isEqualToString:@"UserProfileSegue"])
    if ([segue.identifier isEqualToString:@"OTSelectedTourSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTFeedItemViewController *controller = (OTFeedItemViewController *)navController.topViewController;
        controller.feedItem = (OTFeedItem*)sender;
        [controller configureWithTour:controller.feedItem];
    } else if ([segue.identifier isEqualToString:@"OTTourJoinRequestSegue"]) {
        //We shouldn't arrive here
    } else if ([segue.identifier isEqualToString:@"QuitFeedItemSegue"]) {
        OTQuitFeedItemViewController *controller = (OTQuitFeedItemViewController *)segue.destinationViewController;
        controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.feedItem = (OTFeedItem*)sender;
    } else if ([segue.identifier isEqualToString:@"OTConfirmationPopup"]) {
        OTConfirmationViewController *controller = (OTConfirmationViewController *)segue.destinationViewController;
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.view.backgroundColor = [UIColor appModalBackgroundColor];
        controller.delegate = self;
        [controller configureWithTour:(OTTour*)sender
                   andEncountersCount:[NSNumber numberWithUnsignedInteger:0]];
    }
}

/**************************************************************************************************/
#pragma mark - Private

- (void)setupPagination {
    self.activeToursPagination = [OTToursPagination new];
    self.closedToursPagination = [OTToursPagination new];
}

- (void)configureTableView {
    self.tableView.feedItemsDelegate = self;
}

- (void)getEntouragesWithStatus:(NSInteger) entourageStatus {
    NSString *statusString = TOUR_STATUS_ONGOING;
    NSInteger page = 1;
    
    OTToursPagination *currentPagination = nil;
    
    switch (entourageStatus) {
        case EntourageStatusActive:
            statusString = FEEDITEM_STATUS_ACTIVE;
            currentPagination = self.activeToursPagination;
            page = self.activeToursPagination.page;
            break;
        case EntourageStatusClosed:
            statusString = FEEDITEM_STATUS_CLOSED;
            currentPagination = self.closedToursPagination;
            break;
            
        default:
            break;
    }
    
    if (currentPagination != nil) {
        if (currentPagination.isLoading) {
            return;
        }
        page = currentPagination.page;
        currentPagination.isLoading = YES;
    }
    
    //NSLog(@"getting tours with status %@ ...", statusString);
    __block NSInteger requestedStatus = entourageStatus;
    [self.indicatorView startAnimating];
    NSLog(@"Getting data ...");
    [[OTFeedsService new] getMyFeedsWithStatus:statusString
                                 andPageNumber:@(page)
                              andNumberPerPage:@TOURS_PER_PAGE
                                       success:^(NSMutableArray *userTours) {
                                           [self.indicatorView stopAnimating];
                                           switch (requestedStatus) {
                                               case EntourageStatusActive:
                                                   [self.activeToursPagination addTours:userTours];
                                                   break;
                                               case EntourageStatusClosed:
                                                   [self.closedToursPagination addTours:userTours];
                                                   break;
                                                   
                                               default:
                                                   break;
                                           }
                                           if (userTours == nil || userTours.count == 0) return;
                                           if (requestedStatus != self.statusSC.selectedSegmentIndex) return;
                                           [self.tableView addFeedItems:userTours];
                                           [self.tableView reloadData];

                                       } failure:^(NSError *error) {
                                           [self.indicatorView stopAnimating];
                                           switch (requestedStatus) {
                                               case EntourageStatusActive:
                                                   self.activeToursPagination.isLoading = NO;
                                                   break;
                                               case EntourageStatusClosed:
                                                   self.closedToursPagination.isLoading = NO;
                                                   break;
                                                   
                                               default:
                                                   break;
                                           }

                                       }];
}

- (IBAction)changedSegmentedControlSelection:(UISegmentedControl *)segControl {
    //Update the table view
    [self.tableView removeAll];
    switch (segControl.selectedSegmentIndex) {
        case EntourageStatusActive:
            [self.tableView addFeedItems:self.activeToursPagination.tours];
            break;
        case EntourageStatusClosed:
            [self.tableView addFeedItems:self.closedToursPagination.tours];
            break;
            
        default:
            break;
    }
    [self.tableView reloadData];
    
    //Retrieve more tours
    [self getData];
}

/**************************************************************************************************/
#pragma mark - OTFeedItemsTableViewDelegate

- (void)showFeedInfo:(OTFeedItem *)feedItem {
    [self performSegueWithIdentifier:@"OTSelectedTourSegue" sender:feedItem];
}

- (void)showUserProfile:(NSNumber*)userId {
    [self performSegueWithIdentifier:@"UserProfileSegue" sender:userId];
}

- (void)doJoinRequest:(OTTour*)tour {
    
    // TODO: test each branch
    if ([tour.joinStatus isEqualToString:JOIN_NOT_REQUESTED])
    {
        //We shouldn't arrive here
        //[self performSegueWithIdentifier:@"OTTourJoinRequestSegue" sender:tour];
    }
    else  if ([tour.joinStatus isEqualToString:JOIN_PENDING])
    {
        [self performSegueWithIdentifier:@"OTSelectedTourSegue" sender:tour];
    }
    else
    {
        OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
        if (currentUser.sid.intValue == tour.author.uID.intValue && tour.status != nil) {
            if ([tour.status isEqualToString:TOUR_STATUS_ONGOING]) {
                [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:tour];
            } else {
                tour.status = TOUR_STATUS_FREEZED;
                [self.indicatorView startAnimating];
                [[OTTourService new] closeTour:tour
                                   withSuccess:^(OTTour *closedTour) {
                                       [self.indicatorView stopAnimating];
                                       [self.closedToursPagination.tours removeObject:tour];
                                       NSInteger selectedSegmentIndex = self.statusSC.selectedSegmentIndex;
                                       if (selectedSegmentIndex == EntourageStatusClosed) {
                                           [self.tableView removeFeedItem:tour];
                                           [self.tableView reloadData];
                                       }
                                   } failure:^(NSError *error) {
                                       [self.indicatorView stopAnimating];
                                       [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"error")];
                                       NSLog(@"%@",[error localizedDescription]);
                                       tour.status = FEEDITEM_STATUS_CLOSED;
                                   }];
            }
        } else {
            [self performSegueWithIdentifier:@"QuitFeedItemSegue" sender:tour];
        }
    }
}

- (void)getData {
    [self getEntouragesWithStatus:self.statusSC.selectedSegmentIndex];
}

- (void)loadMoreData {
    [self getData];
}

/**************************************************************************************************/
#pragma mark - OTConfirmationViewControllerDelegate

- (void)tourSent:(OTTour*)tour {
    if (tour == nil) return;
    [self.activeToursPagination.tours removeObject:tour];
    [self.closedToursPagination.tours addObject:tour];
    NSInteger selectedSegmentIndex = self.statusSC.selectedSegmentIndex;
    if (selectedSegmentIndex == EntourageStatusActive) {
        [self.tableView removeFeedItem:tour];
        [self.tableView reloadData];
    }
    else if (selectedSegmentIndex == EntourageStatusClosed) {
        [self.tableView addFeedItem:tour];
        [self.tableView reloadData];
    }
    if (self.mainViewController != nil && [self.mainViewController respondsToSelector:@selector(tourSent:)]) {
        [self.mainViewController tourSent:tour];
    }
}

- (void)resumeTour {
    
}

@end
