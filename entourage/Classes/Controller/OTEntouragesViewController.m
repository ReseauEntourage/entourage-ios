//
//  OTEntouragesViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 26/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

// Controllers
#import "OTEntouragesViewController.h"
#import "OTToursTableView.h"
#import "OTTourViewController.h"
#import "OTPublicTourViewController.h"
#import "OTQuitTourViewController.h"
#import "OTConfirmationViewController.h"
#import "OTMainViewController.h"

// Services
#import "OTTourService.h"
#import "OTUser.h"
#import "OTTour.h"

// Helpers
#import "NSUserDefaults+OT.h"
#import "UIViewController+menu.h"
#import "UIColor+entourage.h"
#import "SVProgressHUD.h"

#define TOURS_PER_PAGE 10

typedef NS_ENUM(NSInteger){
    EntourageStatusOpen,
    EntourageStatusClosed,
    EntourageStatusFreezed
    
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

@interface OTEntouragesViewController() <OTToursTableViewDelegate, OTConfirmationViewControllerDelegate>

// UI
@property (nonatomic, weak) IBOutlet UISegmentedControl *statusSC;
@property (nonatomic, weak) IBOutlet OTToursTableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;

// Pagination
@property (nonatomic, strong) OTToursPagination *openToursPagination;
@property (nonatomic, strong) OTToursPagination *closedToursPagination;
@property (nonatomic, strong) OTToursPagination *freezedToursPagination;

@end


@implementation OTEntouragesViewController

/**************************************************************************************************/
#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MES MARAUDES";
    [self setupCloseModal];
    
    [self setupPagination];
    [self configureTableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.statusSC setSelectedSegmentIndex:EntourageStatusClosed];
    [self changedSegmentedControlSelection:self.statusSC];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UserProfileSegue"]) {
        
    } else if ([segue.identifier isEqualToString:@"OTPublicTourSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTPublicTourViewController *controller = (OTPublicTourViewController *)navController.topViewController;
        controller.tour = (OTTour*)sender;
    } else if ([segue.identifier isEqualToString:@"OTSelectedTourSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTTourViewController *controller = (OTTourViewController *)navController.topViewController;
        controller.tour = (OTTour*)sender;
        [controller configureWithTour:controller.tour];
    } else if ([segue.identifier isEqualToString:@"OTTourJoinRequestSegue"]) {
        //We shouldn't arrive here
    } else if ([segue.identifier isEqualToString:@"QuitTourSegue"]) {
        OTQuitTourViewController *controller = (OTQuitTourViewController *)segue.destinationViewController;
        controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.tour = (OTTour*)sender;
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
    self.openToursPagination = [OTToursPagination new];
    self.closedToursPagination = [OTToursPagination new];
    self.freezedToursPagination = [OTToursPagination new];
}

- (void)configureTableView {
    self.tableView.toursDelegate = self;
}

- (void)getEntouragesWithStatus:(NSInteger) entourageStatus {
    NSString *statusString = TOUR_STATUS_ONGOING;
    NSInteger page = 1;
    
    OTToursPagination *currentPagination = nil;
    
    switch (entourageStatus) {
        case EntourageStatusOpen:
            statusString = TOUR_STATUS_ONGOING;
            currentPagination = self.openToursPagination;
            page = self.openToursPagination.page;
            break;
        case EntourageStatusClosed:
            statusString = TOUR_STATUS_CLOSED;
            currentPagination = self.closedToursPagination;
            break;
        case EntourageStatusFreezed:
            statusString = TOUR_STATUS_FREEZED;
            page = self.freezedToursPagination.page;
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
    [[OTTourService new] toursByUserId:[[NSUserDefaults standardUserDefaults] currentUser].sid
                            withStatus:statusString
                         andPageNumber:[NSNumber numberWithInteger:page]
                      andNumberPerPage:@TOURS_PER_PAGE
                               success:^(NSMutableArray *userTours) {
                                   [self.indicatorView stopAnimating];
                                   switch (requestedStatus) {
                                       case EntourageStatusOpen:
                                           [self.openToursPagination addTours:userTours];
                                           break;
                                       case EntourageStatusClosed:
                                           [self.closedToursPagination addTours:userTours];
                                           break;
                                       case EntourageStatusFreezed:
                                           [self.freezedToursPagination addTours:userTours];
                                           break;
                                           
                                       default:
                                           break;
                                   }
                                   if (userTours == nil || userTours.count == 0) return;
                                   if (requestedStatus != self.statusSC.selectedSegmentIndex) return;
                                   [self.tableView addTours:userTours];
                                   [self.tableView reloadData];
                               }
                               failure:^(NSError *error) {
                                   [self.indicatorView stopAnimating];
                                   switch (requestedStatus) {
                                       case EntourageStatusOpen:
                                           self.openToursPagination.isLoading = NO;
                                           break;
                                       case EntourageStatusFreezed:
                                           self.freezedToursPagination.isLoading = NO;
                                           break;
                                       case EntourageStatusClosed:
                                           self.closedToursPagination.isLoading = NO;
                                           break;
                                           
                                       default:
                                           break;
                                   }
        
                               }
     ];
}

- (IBAction)changedSegmentedControlSelection:(UISegmentedControl *)segControl {
    //Update the table view
    [self.tableView removeAll];
    switch (segControl.selectedSegmentIndex) {
        case EntourageStatusOpen:
            [self.tableView addTours:self.openToursPagination.tours];
            break;
        case EntourageStatusClosed:
            [self.tableView addTours:self.closedToursPagination.tours];
            break;
        case EntourageStatusFreezed:
            [self.tableView addTours:self.freezedToursPagination.tours];
            break;
            
        default:
            break;
    }
    [self.tableView reloadData];
    
    //Retrieve more tours
    [self getEntouragesWithStatus:segControl.selectedSegmentIndex];
}

/**************************************************************************************************/
#pragma mark - OTToursTableViewDelegate

- (void)showTourInfo:(OTTour*)tour {
    if ([tour.joinStatus isEqualToString:@"accepted"]) {
        [self performSegueWithIdentifier:@"OTSelectedTourSegue" sender:tour];
    }
    else
    {
        [self performSegueWithIdentifier:@"OTPublicTourSegue" sender:tour];
    }
}

- (void)showUserProfile:(NSNumber*)userId {
    [self performSegueWithIdentifier:@"UserProfileSegue" sender:userId];
}

- (void)doJoinRequest:(OTTour*)tour {
    if ([tour.joinStatus isEqualToString:JOIN_NOT_REQUESTED])
    {
        //We shouldn't arrive here
        //[self performSegueWithIdentifier:@"OTTourJoinRequestSegue" sender:tour];
    }
    else  if ([tour.joinStatus isEqualToString:JOIN_PENDING])
    {
        [self performSegueWithIdentifier:@"OTPublicTourSegue" sender:tour];
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
                                       [self.freezedToursPagination.tours addObject:tour];
                                       NSInteger selectedSegmentIndex = self.statusSC.selectedSegmentIndex;
                                       if (selectedSegmentIndex == EntourageStatusClosed) {
                                           [self.tableView removeTour:tour];
                                           [self.tableView reloadData];
                                       }
                                       else if (selectedSegmentIndex == EntourageStatusFreezed) {
                                           [self.tableView addTour:tour];
                                           [self.tableView reloadData];
                                       }
                                   } failure:^(NSError *error) {
                                       [self.indicatorView stopAnimating];
                                       [SVProgressHUD showErrorWithStatus:@"Erreur"];
                                       NSLog(@"%@",[error localizedDescription]);
                                       tour.status = TOUR_STATUS_CLOSED;
                                   }];
            }
        } else {
            [self performSegueWithIdentifier:@"QuitTourSegue" sender:tour];
        }
    }
}

- (void)loadMoreTours {
    [self getEntouragesWithStatus:self.statusSC.selectedSegmentIndex];
}

/**************************************************************************************************/
#pragma mark - OTConfirmationViewControllerDelegate

- (void)tourSent:(OTTour*)tour {
    if (tour == nil) return;
    [self.openToursPagination.tours removeObject:tour];
    [self.closedToursPagination.tours addObject:tour];
    NSInteger selectedSegmentIndex = self.statusSC.selectedSegmentIndex;
    if (selectedSegmentIndex == EntourageStatusOpen) {
        [self.tableView removeTour:tour];
        [self.tableView reloadData];
    }
    else if (selectedSegmentIndex == EntourageStatusClosed) {
        [self.tableView addTour:tour];
        [self.tableView reloadData];
    }
    if (self.mainViewController != nil && [self.mainViewController respondsToSelector:@selector(tourSent:)]) {
        [self.mainViewController tourSent:tour];
    }
}

- (void)resumeTour {
    
}

@end
