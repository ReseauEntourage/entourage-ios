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

#define TAG_ORGANIZATION 1
#define TAG_TOURTYPE 2
#define TAG_TOURUSER 3

typedef NS_ENUM(unsigned) {
    SectionTypeHeader,
    SectionTypeTimeline
} SectionType;

@interface OTTourViewController ()

@end

@implementation OTTourViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MARAUDE";
    [self setupCloseModal];
    [self setupMoreButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSString *date = [self formatDateForDisplay:self.tour.startTime];
    NSString *startTime = [self formatHourForDisplay:self.tour.startTime];
    NSString *endTime = [self formatHourForDisplay:self.tour.endTime];
    NSString *image;
    NSString *vehicle;
    NSString *type;
    NSString *status;
    
    if ([self.tour.vehicleType isEqualToString:@"feet"]) {
        vehicle = @"A pieds";
    }
    else if ([self.tour.vehicleType isEqualToString:@"car"]) {
        vehicle = @"En voiture";
    }
    
    if ([self.tour.tourType isEqualToString:@"barehands"]) {
        image = @"ic_bare_hands.png";
        type = @"A mains nues";
    }
    else if ([self.tour.tourType isEqualToString:@"medical"]) {
        image = @"ic_medical.png";
        type = @"Médicale";
    }
    else if ([self.tour.tourType isEqualToString:@"alimentary"]) {
        image = @"ic_alimentary.png";
        type = @"Alimentaire";
    }
    
    if ([self.tour.status isEqualToString:@"ongoing"]) {
        status = @"En cours";
    }
    else if ([self.tour.status isEqualToString:@"closed"]) {
        status = @"Terminée";
    }
    
    //self.tourTypeImage.image = [UIImage imageNamed:image];
//    self.dateLabel.text = date;
//    self.startTime.text = startTime;
//    self.endTime.text = endTime;
//    self.organizationNameLabel.text = self.tour.organizationName;
//    self.transportTypeLabel.text = vehicle;
//    self.tourTypeLabel.text = type;
//    self.tourStatusLabel.text = status;
}

/**************************************************************************************************/
#pragma mark - Private Methods
- (void)setupMoreButtons {
    UIImage *plusImage = [[UIImage imageNamed:@"userPlus.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] init];
    [plusButton setImage:plusImage];
    [plusButton setTarget:self];
    //[moreButton setAction:@selector(dismissModal)];

    
    UIImage *moreImage = [[UIImage imageNamed:@"more.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] init];
    [moreButton setImage:moreImage];
    [moreButton setTarget:self];
    //[moreButton setAction:@selector(dismissModal)];
    
    [self.navigationItem setRightBarButtonItems:@[moreButton]];
    //[self.navigationItem setRightBarButtonItem:moreButton];

}


/**************************************************************************************************/
#pragma mark - Public Methods

- (void)configureWithTour:(OTTour *)tour {
    self.tour = tour;
}

- (NSString *)formatDateForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    return [formatter stringFromDate:date];
}

- (NSString *)formatHourForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH'h'mm"];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionTypeHeader:
            return 1;
        case SectionTypeTimeline:
            return 2;
            
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
        case SectionTypeTimeline:
            cellID = @"TourStatusCell";
            break;
        default:
            break;
    }

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (indexPath.section == SectionTypeHeader) {
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
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionTypeHeader:
            return  70.0f;
        case SectionTypeTimeline:
            return 157.0f;
            
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


@end
