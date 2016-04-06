//
//  OTEntouragesViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 26/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntouragesViewController.h"
#import "OTToursTableView.h"
#import "UIViewController+menu.h"
#import "OTTourService.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"

#define TOURS_PER_PAGE 10

#define STATUS_OPEN @"open"
#define STATUS_FREEZED @"freezed"
#define STATUS_CLOSED @"closed"


typedef NS_ENUM(NSInteger){
    EntourageStatusOpen,
    EntourageStatusClosed,
    EntourageStatusFreezed
    
} EntourageStatus;

/**************************************************************************************************/
#pragma mark - OTToursPagination

@interface OTToursPagination : NSObject

@property (nonatomic) NSInteger page;
@property (nonatomic, strong) NSMutableArray *tours;

@end

@implementation OTToursPagination

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.page = 1;
        self.tours = [NSMutableArray new];
    }
    return self;
}

@end

/**************************************************************************************************/
#pragma mark - OTEntouragesViewController

@interface OTEntouragesViewController() <OTToursTableViewDelegate>

// UI
@property (nonatomic, weak) IBOutlet UISegmentedControl *statusSC;
@property (nonatomic, weak) IBOutlet OTToursTableView *tableView;

// Pagination
@property (nonatomic, strong) OTToursPagination *openToursPagination;
@property (nonatomic, strong) OTToursPagination *closedToursPagination;
@property (nonatomic, strong) OTToursPagination *freezedToursPagination;

@end


@implementation OTEntouragesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MES ENTOURAGES";
    [self setupCloseModal];
    
    [self setupPagination];
    [self configureTableView];
    
//    [self.statusSC setSelectedSegmentIndex:EntourageStatusOpen];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.statusSC setSelectedSegmentIndex:EntourageStatusClosed];
    [self changedSegmentedControlSelection:self.statusSC];
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
    NSString *statusString = STATUS_OPEN;
    NSInteger page = 1;
    
    switch (entourageStatus) {
        case EntourageStatusOpen:
            statusString = STATUS_OPEN;
            page = self.openToursPagination.page;
            break;
        case EntourageStatusFreezed:
            statusString = STATUS_FREEZED;
            page = self.closedToursPagination.page;
            break;
        case EntourageStatusClosed:
            statusString = STATUS_CLOSED;
            page = self.freezedToursPagination.page;
            break;
            
        default:
            break;
    }
    
    NSLog(@"getting tours with status %@ ...", statusString);
    __block NSInteger requestedStatus = entourageStatus;
    [[OTTourService new] toursByUserId:[[NSUserDefaults standardUserDefaults] currentUser].sid
                            withStatus:statusString
                         andPageNumber:[NSNumber numberWithInteger:page]
                      andNumberPerPage:@TOURS_PER_PAGE
                               success:^(NSMutableArray *userTours) {
                                   if (userTours == nil || userTours.count == 0) return;
                                   switch (requestedStatus) {
                                       case EntourageStatusOpen:
                                           self.openToursPagination.page++;
                                           [self.openToursPagination.tours addObjectsFromArray:userTours];
                                           [self.tableView addTours:userTours];
                                           [self.tableView reloadData];
                                           break;
                                       case EntourageStatusFreezed:
                                           self.closedToursPagination.page++;
                                           [self.closedToursPagination.tours addObjectsFromArray:userTours];
                                           [self.tableView addTours:userTours];
                                           [self.tableView reloadData];
                                           break;
                                       case EntourageStatusClosed:
                                           self.freezedToursPagination.page++;
                                           [self.freezedToursPagination.tours addObjectsFromArray:userTours];
                                           [self.tableView addTours:userTours];
                                           [self.tableView reloadData];
                                           break;
                                           
                                       default:
                                           break;
                                   }
                               }
                               failure:^(NSError *error) {
        
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
        case EntourageStatusFreezed:
            [self.tableView addTours:self.closedToursPagination.tours];
            break;
        case EntourageStatusClosed:
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
    
}

- (void)showUserProfile:(NSNumber*)userId {
    
}

- (void)doJoinRequest:(OTTour*)tour {
    
}

@end
