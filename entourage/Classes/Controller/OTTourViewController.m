//
//  OTTourViewController.m
//  entourage
//
//  Created by Nicolas Telera on 20/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import "OTTourViewController.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTOrganization.h"
#import "UIViewController+menu.h"
#import "UIColor+entourage.h"
#import "UIButton+AFNetworking.h"
#import "OTTourDetailsOptionsViewController.h"
#import "OTTourService.h"

#import "OTTourJoiner.h"
#import "OTEncounter.h"
#import "OTTourMessage.h"
@class OTTourStatus;

#define TAG_ORGANIZATION 1
#define TAG_TOURTYPE 2
#define TAG_TOURUSER 3

typedef NS_ENUM(unsigned) {
    SectionTypeHeader,
    SectionTypeTimeline
} SectionType;


@interface OTTourViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *timelinePoints;
@property (nonatomic, strong) NSDictionary *timelineCardsClassesCellsIDs;
@end

@implementation OTTourViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MARAUDE";
    [self setupCloseModal];
    [self setupMoreButtons];
    
    self.timelineCardsClassesCellsIDs = @{@"OTTourJoiner": @"TourJoinerCell",
                                          @"OTTourMessage": @"TourJoinerCell",
                                          @"OTEncounter": @"TourEncounterCell",
                                          @"OTTourStatus": @"TourStatusCell"};
    
    self.timelinePoints = [[NSMutableArray alloc] init];
    [self getTourUsersJoins];
    [self getTourMessages];
    [self getTourEncounters];
}

/**************************************************************************************************/
#pragma mark - Private Methods
- (void)setupMoreButtons {
    UIImage *plusImage = [[UIImage imageNamed:@"userPlus.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] init];
    [plusButton setImage:plusImage];
    [plusButton setTarget:self];
    //[plusButton setAction:@selector(addUser)];

    
    UIImage *moreImage = [[UIImage imageNamed:@"more.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] init];
    [moreButton setImage:moreImage];
    [moreButton setTarget:self];
    [moreButton setAction:@selector(showOptions)];
    
    [self.navigationItem setRightBarButtonItems:@[moreButton]];
    //[self.navigationItem setRightBarButtonItem:moreButton];
}

- (void)showOptions {
    [self performSegueWithIdentifier:@"TourOptionsSegue" sender:nil];
}

- (void)updateTableViewAddingTimelinePoints:(NSArray *)timelinePoints {
    [self.timelinePoints addObjectsFromArray:timelinePoints];
    self.timelinePoints = [self.timelinePoints sortedArrayUsingSelector:@selector(compare:)].mutableCopy;
    [self.tableView reloadData];
}


#pragma mark - Service
- (void)getTourUsersJoins {
    [[OTTourService new] tourUsersJoins:self.tour
                                success:^(NSArray *tourUsers) {
                                    NSLog(@"USERS: %@", tourUsers);
                                    [self updateTableViewAddingTimelinePoints:tourUsers];
    } failure:^(NSError *error) {
        NSLog(@"USERSerr %@", error.description);
    }];
}

- (void)getTourMessages {
    [[OTTourService new] tourMessages:self.tour
                                success:^(NSArray *tourMessages) {
                                    NSLog(@"MESSAGES: %@", tourMessages);
                                    [self updateTableViewAddingTimelinePoints:tourMessages];

    } failure:^(NSError *error) {
        NSLog(@"MESSAGESerr %@", error.description);
    }];
}

- (void)getTourEncounters {
    [[OTTourService new] tourEncounters:self.tour
                              success:^(NSArray *tourEncounters) {
                                  NSLog(@"ENCOUNTERS: %@", tourEncounters);
                                  [self updateTableViewAddingTimelinePoints:tourEncounters];
                              } failure:^(NSError *error) {
                                  NSLog(@"ENCOUNTERSSerr %@", error.description);
                              }];
}


/**************************************************************************************************/
#pragma mark - Public Methods

- (void)configureWithTour:(OTTour *)tour {
    self.tour = tour;
}

- (NSString *)formatDateForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"EEE"];
    return [formatter stringFromDate:date];
}

- (NSString *)formatHourForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH':'mm"];
    return [formatter stringFromDate:date];
}

- (NSString *)formatHourToSecondsForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH':'mm':'ss"];
    return [formatter stringFromDate:date];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**************************************************************************************************/
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionTypeHeader:
            return 1;
        case SectionTypeTimeline:
            return self.timelinePoints.count;
            
        default:
            return 0.0f;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SectionTypeHeader:
            return 15.0f;
        case SectionTypeTimeline:
            return 40.0f;
            
        default:
            return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    if (section == SectionTypeTimeline) {
        headerView.backgroundColor = [UIColor clearColor];
        headerView.text = @"DISCUSSION";
        headerView.textAlignment = NSTextAlignmentCenter;
        headerView.textColor = [UIColor appGreyishBrownColor];
        headerView.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"";
    switch (indexPath.section) {
        case SectionTypeHeader:
            cellID = @"TourDetailsCell";
            break;
        case SectionTypeTimeline: {
            NSString *timelinePointClassName = NSStringFromClass([ self.timelinePoints[indexPath.row] class]);
            cellID = [self.timelineCardsClassesCellsIDs valueForKey:timelinePointClassName];
        }
            break;
        default:
            break;
    }

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (indexPath.section == SectionTypeHeader) {
        [self setupHeaderCell:cell];
    } else {
        switch (((OTTourTimelinePoint *)self.timelinePoints[indexPath.row]).tag) {
            case TimelinePointTagEncounter:
                [self setupEncounterCell:cell withEncounter:((OTEncounter *)self.timelinePoints[indexPath.row])];
                break;
            case TimelinePointTagJoiner:
                [self setupJoinerCell:cell withJoiner:((OTTourJoiner *)self.timelinePoints[indexPath.row])];
                break;
            case TimelinePointTagMessage:
            case TimelinePointTagStatus:
                
            default:
                break;
        }
    }
    return cell;
}




#define TIMELINE_TIME_TAG 10
#define TIMELINE_STATUS_TAG 11
#define TIMELINE_DURATION_TAG 12
#define TIMELINE_KM_TAG 13

#define TIMELINE_ENCOUNTER 100
#define TIMELINE_JOINER 200

- (void)setupEncounterCell:(UITableViewCell *)cell withEncounter:(OTEncounter *)encounter {
    //User et Encounter se sont rencontrés ici.
    NSString *text = [NSString stringWithFormat:@"%@ et %@ se sont rencontrés ici.", encounter.userName, encounter.streetPersonName];
    UILabel *encounterLabel = [cell viewWithTag:TIMELINE_ENCOUNTER];
    encounterLabel.text = text;
}

- (void)setupJoinerCell:(UITableViewCell *)cell withJoiner:(OTTourJoiner *)joiner {
    NSString *text = [NSString stringWithFormat:@"%@ a rejoint votre maraude.", joiner.displayName];
    UILabel *joinerLabel = [cell viewWithTag:TIMELINE_JOINER];
    joinerLabel.text = text;
}


- (void)setupHeaderCell:(UITableViewCell *)cell {
    OTTourAuthor *author = self.tour.author;
    UILabel *organizationLabel = [cell viewWithTag:TAG_ORGANIZATION];
    organizationLabel.text = self.tour.organizationName;
    
    
    NSString *tourType = self.tour.tourType;
    if ([tourType isEqualToString:@"barehands"]) {
        tourType = @"sociale";
    } else     if ([tourType isEqualToString:@"medical"]) {
        tourType = @"médicale";
    } else if ([tourType isEqualToString:@"alimentary"]) {
        tourType = @"distributive";
    }
    NSDictionary *lightAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightLight]};
    NSDictionary *boldAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold]};
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Mauraude %@ par ", tourType] attributes:lightAttrs];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:author.displayName attributes:boldAttrs];
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:nameAttrString];
    UILabel *typeByNameLabel = [cell viewWithTag:TAG_TOURTYPE];
    typeByNameLabel.attributedText = typeByNameAttrString;
    
    
    __weak UIButton *userImageButton = [cell viewWithTag:TAG_TOURUSER];
    userImageButton.layer.cornerRadius = userImageButton.bounds.size.height/2.f;
    userImageButton.clipsToBounds = YES;
    if (self.tour.author.avatarUrl != nil) {
        NSURL *url = [NSURL URLWithString:self.tour.author.avatarUrl];
        UIImage *placeholderImage = [UIImage imageNamed:@"userSmall"];
        [userImageButton setImageForState:UIControlStateNormal
                                  withURL:url
                         placeholderImage:placeholderImage];
    }

}

- (void)setupCell:(UITableViewCell *)cell withStatutOngoingOfTour:(OTTour*)tour {
    UILabel *timeLabel = [cell viewWithTag:TIMELINE_TIME_TAG];
    NSString *day  = [self formatDateForDisplay:tour.startTime];
    NSString *time = [self formatHourForDisplay:tour.startTime];
    timeLabel.text = [NSString stringWithFormat:@"%@. %@", [day uppercaseString], time];
    
    UILabel *statusLabel = [cell viewWithTag:TIMELINE_STATUS_TAG];
    statusLabel.text = @"Maraude en cours";
    
    UILabel *durationLabel = [cell viewWithTag:TIMELINE_DURATION_TAG];
    durationLabel.text = @"";
    
    UILabel *kmLabel = [cell viewWithTag:TIMELINE_KM_TAG];
    kmLabel.text = @"";
    
}

- (void)setupCell:(UITableViewCell *)cell withStatutEndOfTour:(OTTour*)tour {
    UILabel *timeLabel = [cell viewWithTag:TIMELINE_TIME_TAG];
    NSString *day  = [self formatDateForDisplay:tour.endTime];
    NSString *time = [self formatHourForDisplay:tour.endTime];
    
    timeLabel.text = [NSString stringWithFormat:@"%@. %@", [day uppercaseString], time];
    
    UILabel *statusLabel = [cell viewWithTag:TIMELINE_STATUS_TAG];
    statusLabel.text = @"Maraude terminée";
    
    UILabel *durationLabel = [cell viewWithTag:TIMELINE_DURATION_TAG];
    NSTimeInterval interval = [tour.endTime timeIntervalSinceDate:tour.startTime];
    durationLabel.text = [self formatHourToSecondsForDisplay:[NSDate dateWithTimeIntervalSince1970: interval]];
    
    UILabel *kmLabel = [cell viewWithTag:TIMELINE_KM_TAG];
    kmLabel.text = [NSString stringWithFormat:@"%.2fkm", tour.distance];
}

#define CELLHEIGHT_JOINER 49.0f
#define CELLHEIGHT_ENCOUNTER 49.0f
#define CELLHEIGHT_STATUS 157.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionTypeHeader:
            return  70.0f;
        case SectionTypeTimeline: {
            OTTourTimelinePoint *timelinePoint = self.timelinePoints[indexPath.row];
            if ([timelinePoint isKindOfClass:[OTTourJoiner class]])
                return CELLHEIGHT_JOINER;
            if ([timelinePoint isKindOfClass:[OTEncounter class]])
                return CELLHEIGHT_ENCOUNTER;
            if ([timelinePoint isKindOfClass:[NSString class]])
                return CELLHEIGHT_STATUS;
        }
            
        default:
            return 0.0f;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5f;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.selectedTour = self.tours[indexPath.row];
//    [self performSegueWithIdentifier:@"OTSelectedTour" sender:self];
//}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    OTTourDetailsOptionsViewController *controller = (OTTourDetailsOptionsViewController *)segue.destinationViewController;
    controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
    [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    
}

@end
