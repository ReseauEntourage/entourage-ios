//
//  OTNewsFeedsFilter.m
//  entourage
//
//  Created by sergiu buceac on 8/22/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTNewsFeedsFilter.h"
#import "OTConsts.h"
#import "OTFeedItemFilter.h"
#import "OTFeedItemTimeframeFilter.h"
#import "OTTour.h"
#import "OTEntourage.h"
#import "NSUserDefaults+OT.h"
#import "OTSavedFilter.h"
#import "OTAPIConsts.h"
#import "OTCategoryFromJsonService.h"
#import "OTCategoryType.h"
#import "entourage-Swift.h"

#define FEEDS_REQUEST_DISTANCE_KM 10

@interface OTNewsFeedsFilter ()

@property (nonatomic, strong) NSDictionary *categoryDictionary;
@property(nonatomic) BOOL isAnnouncementOnly;
@property (nonatomic) BOOL isVersionAlone;
@end;

@implementation OTNewsFeedsFilter

-(instancetype) initFromNewFeed {
    self = [super init];
    if (self) {
        self.isAnnouncementOnly = NO;
        self.isPro = IS_PRO_USER;
        self.showOnlyMyEntourages = NO;
        
        self.showPartners = NO;
        self.showAlls = YES;
        self.showNeighborhood = YES;
        self.showPrivateCircle = YES;
       
        if (self.isVersionAlone) {
            self.showOuting = NO;
        }
        else {
            self.showOuting = YES;
        }
        
        self.showPastOuting = NO;
        
        self.showMedical = self.isPro;
        self.showSocial = self.isPro;
        self.showDistributive = self.isPro;
        self.showDemand = YES;
        self.showContribution = YES;
        self.showTours = self.isPro;
        
        self.showDemandeSocial = YES;
        self.showDemandeHelp = YES;
        self.showDemandeResource = YES;
        self.showDemandeInfo = YES;
        self.showDemandeSkill = YES;
        self.showDemandeOther = YES;
        
        self.showContributionSocial = YES;
        self.showContributionHelp = YES;
        self.showContributionResource = YES;
        self.showContributionInfo = YES;
        self.showContributionSkill = YES;
        self.showContributionOther = YES;
        
        self.timeframeInHours = 30 * 24;
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    self.isAnnouncementOnly = NO;
    if (self) {
        self.isPro = IS_PRO_USER;
        OTSavedFilter *savedFilter = [NSUserDefaults standardUserDefaults].savedNewsfeedsFilter;
        self.showOnlyMyEntourages = NO;
        
        if (savedFilter) {
            
            self.showOuting = savedFilter.showOuting.boolValue;
            self.showPastOuting = !self.showOuting ? self.showOuting : savedFilter.showPastOuting.boolValue;
            
            self.showNeighborhood = savedFilter.showNeighborhood.boolValue;
            self.showPrivateCircle = savedFilter.showPrivateCircle.boolValue;
            
            self.showTours = savedFilter.showTours.boolValue;
            
            self.showMedical = !self.showTours ? self.showTours : savedFilter.showMedical.boolValue;
            self.showSocial = !self.showTours ? self.showTours : savedFilter.showSocial.boolValue;
            self.showDistributive = !self.showTours ? self.showTours : savedFilter.showDistributive.boolValue;
            
            self.showDemand = savedFilter.showDemand.boolValue;
            self.showContribution = savedFilter.showContribution.boolValue;
            self.timeframeInHours = savedFilter.timeframeInHours.intValue;
            self.showFromOrganisation = savedFilter.showFromOrganisation.boolValue;
            self.showOnlyMyEntourages = savedFilter.showOnlyMyEntourages.boolValue;
            
            self.showDemandeSocial = !self.showDemand ? self.showDemand : savedFilter.showDemandeSocial.boolValue;
            self.showDemandeHelp = !self.showDemand ? self.showDemand : savedFilter.showDemandeHelp.boolValue;
            self.showDemandeResource = !self.showDemand ? self.showDemand : savedFilter.showDemandeResource.boolValue;
            self.showDemandeInfo = !self.showDemand ? self.showDemand : savedFilter.showDemandeInfo.boolValue;
            self.showDemandeSkill = !self.showDemand ? self.showDemand : savedFilter.showDemandeSkill.boolValue;
            self.showDemandeOther = !self.showDemand ? self.showDemand : savedFilter.showDemandeOther.boolValue;
            
            self.showContributionSocial = !self.showContribution ? self.showContribution : savedFilter.showContributionSocial.boolValue;
            self.showContributionHelp = !self.showContribution ? self.showContribution : savedFilter.showContributionHelp.boolValue;
            self.showContributionResource = !self.showContribution ? self.showContribution : savedFilter.showContributionResource.boolValue;
            self.showContributionInfo = !self.showContribution ? self.showContribution : savedFilter.showContributionInfo.boolValue;
            self.showContributionSkill = !self.showContribution ? self.showContribution : savedFilter.showContributionSkill.boolValue;
            self.showContributionOther = !self.showContribution ? self.showContribution : savedFilter.showContributionOther.boolValue;
            
            self.showPartners = savedFilter.showPartnersOnly.boolValue;
            self.showAlls = !savedFilter.showPartnersOnly.boolValue;
        }
        else {
            self.showPartners = NO;
            self.showAlls = YES;
            self.showNeighborhood = YES;
            self.showPrivateCircle = YES;
           
            if (self.isVersionAlone) {
                self.showOuting = NO;
            }
            else {
                self.showOuting = YES;
            }
            
            self.showPastOuting = NO;
            
            self.showMedical = self.isPro;
            self.showSocial = self.isPro;
            self.showDistributive = self.isPro;
            self.showDemand = YES;
            self.showContribution = YES;
            self.showTours = self.isPro;
            
            self.showDemandeSocial = YES;
            self.showDemandeHelp = YES;
            self.showDemandeResource = YES;
            self.showDemandeInfo = YES;
            self.showDemandeSkill = YES;
            self.showDemandeOther = YES;
            
            self.showContributionSocial = YES;
            self.showContributionHelp = YES;
            self.showContributionResource = YES;
            self.showContributionInfo = YES;
            self.showContributionSkill = YES;
            self.showContributionOther = YES;
            
            self.timeframeInHours = 30 * 24;
        }
    }
    
    return self;
}

- (NSArray *)groupHeaders {
    
    if (IS_PRO_USER && OTAppConfiguration.supportsTourFunctionality) {
        if (self.isEncouterFilter) {
            return @[
             OTLocalizedString(@"filter_maraudes_title"),
             OTLocalizedString(@"filter_timeframe_title")
             ];
        }
        NSArray *array;
        if (self.isVersionAlone) {
            array = @[
                 OTLocalizedString(@"filter_entourages_title"),
                // OTLocalizedString(@"filter_entourage_from_sympathisants_title"),
                 OTLocalizedString(@"filter_timeframe_title")
                 ];
        }
        else {
            array = @[
                 OTLocalizedString(@"filter_maraudes_title"),
                 [OTAppAppearance eventsFilterTitle],
                 OTLocalizedString(@"filter_entourages_title"),
                // OTLocalizedString(@"filter_entourage_from_sympathisants_title"),
                 OTLocalizedString(@"filter_timeframe_title")
                 ];
        }
        
        return array;
    } else if (![NSUserDefaults standardUserDefaults].currentUser.isAnonymous) {
        
        NSArray *array;
        
        if (self.isVersionAlone) {
            array = @[
                 OTLocalizedString(@"filter_entourages_title"),
                // OTLocalizedString(@"filter_entourage_from_sympathisants_title"),
                 OTLocalizedString(@"filter_publish_title"),
                 OTLocalizedString(@"filter_timeframe_title")
                 ];
        }
        else {
            array = @[
                 OTLocalizedString(@"filter_entourages_title"),
                // OTLocalizedString(@"filter_entourage_from_sympathisants_title"),
                 OTLocalizedString(@"filter_publish_title"),
                 OTLocalizedString(@"filter_timeframe_title")
                 ];
        }
        
        return array;
    } else {
        
        NSArray *array;
        
        if (self.isVersionAlone) {
            array = @[
                 OTLocalizedString(@"filter_entourages_title"),
                 OTLocalizedString(@"filter_timeframe_title")
                 ];
        }
        else {
            array = @[
                 [OTAppAppearance eventsFilterTitle],
                 OTLocalizedString(@"filter_entourages_title"),
                 OTLocalizedString(@"filter_timeframe_title")
                 ];
        }
        
        return array;
    }
}

- (NSArray *)toGroupedArray {
    self.categoryDictionary = @{ @"ask_for_help_social": [NSNumber numberWithBool: self.showDemandeSocial],
                                 @"ask_for_help_mat_help": [NSNumber numberWithBool:self.showDemandeHelp],
                                 @"ask_for_help_resource": [NSNumber numberWithBool:self.showDemandeResource],
                                 @"ask_for_help_info": [NSNumber numberWithBool:self.showDemandeInfo],
                                 @"ask_for_help_skill": [NSNumber numberWithBool:self.showDemandeSkill],
                                 @"ask_for_help_other": [NSNumber numberWithBool:self.showDemandeOther],
                                 
                                 @"contribution_social": [NSNumber numberWithBool:self.showContributionSocial],
                                 @"contribution_mat_help": [NSNumber numberWithBool:self.showContributionHelp],
                                 @"contribution_resource": [NSNumber numberWithBool:self.showContributionResource],
                                 @"contribution_info": [NSNumber numberWithBool:self.showContributionInfo],
                                 @"contribution_skill": [NSNumber numberWithBool:self.showContributionSkill],
                                 @"contribution_other": [NSNumber numberWithBool:self.showContributionOther],
                                 
                                 @"ask_for_help" : [NSNumber numberWithBool:self.showDemand],
                                 @"contribution" : [NSNumber numberWithBool:self.showContribution],
                                 
                                 @"ask_for_help_event" : [NSNumber numberWithBool:self.showOuting],
                                 @"showAlls" : [NSNumber numberWithBool:self.showAlls],
                                 @"showPartners" : [NSNumber numberWithBool:self.showPartners],
                                 };
    
    if (IS_PRO_USER && OTAppConfiguration.supportsTourFunctionality && !self.isVersionAlone) {
        return [self groupForPro];
    }
    else {
        return [self groupForPublic];
    }
}

- (NSArray *)parentArray {
    NSArray *data = [OTCategoryFromJsonService getData];
    NSMutableArray *parentArray = [[NSMutableArray alloc] init];
    
    if (IS_PRO_USER && !self.isVersionAlone) {
        NSArray *tourChildren = @[[OTFeedItemFilter createFor:FeedItemFilterKeyMedical
                                                       active:self.showMedical
                                                    withImage:@"filter_heal"],
                                  [OTFeedItemFilter createFor:FeedItemFilterKeySocial
                                                       active:self.showSocial
                                                    withImage:@"filter_social"],
                                  [OTFeedItemFilter createFor:FeedItemFilterKeyDistributive
                                                       active:self.showDistributive
                                                    withImage:@"filter_eat"]];
        [parentArray addObject:[OTFeedItemFilter createFor:FeedItemFilterKeyTour
                                                    active:self.showTours
                                                  children:tourChildren]];
        
    }
    
    if (!self.isVersionAlone) {
        NSArray *eventChildren = @[[OTFeedItemFilter createFor:FeedItemFilterKeyEvents
                                                        active:self.showOuting
                                                     withImage:@"ask_for_help_event"
                                                         title:[OTAppAppearance eventsFilterTitle]],
                                   [OTFeedItemFilter createFor:FeedItemFilterKeyEventsPast
                                                        active:self.showPastOuting
                                                         title:[OTAppAppearance includePastEventsFilterTitleKey]]];
        [parentArray addObject:[OTFeedItemFilter createFor:FeedItemFilterKeyEvents
                                                    active:self.showOuting
                                                  children:eventChildren
                                                     image:@"ask_for_help_event"
                                              showBoldText:YES]];
    }
    
        
    OTCategoryType *contribution = nil;
    OTCategoryType *demande = nil;
      
    for (OTCategoryType *type in data) {
        if ([type.type isEqualToString:@"contribution"]) {
            contribution = type;
            
        }
        else if ([type.type isEqualToString:@"ask_for_help"]) {
            demande = type;
            
        }
    }
    
    NSArray *contributionArray = [self contributionCategory:contribution];
    [parentArray addObject: [OTFeedItemFilter createFor:FeedItemFilterKeyContribution
                                                 active:self.showContribution
                                               children:contributionArray]];
        
    NSArray *demandeArray = [self demandCategory:demande];
    [parentArray addObject: [OTFeedItemFilter createFor:FeedItemFilterKeyDemand
                                                 active:self.showDemand
                                               children:demandeArray]];
    
    return parentArray;
}

- (NSArray *)groupForPublic {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    // Events section
    if (!self.isVersionAlone) {
        [array addObject:[self groupEntourageEvents]];
    }
    
    [array addObject:[self groupActions]];
//    if (![NSUserDefaults standardUserDefaults].currentUser.isAnonymous) {
//        [array addObject:[self groupUniquement]];
//    }
    
    //TODO: add array Partners
    
    [array addObject:@[[OTFeedItemFilter createFor:FeedItemFilterKeyAlls
                                            active:self.showAlls
                                          children:@[]
                                             image:@""
                                      showBoldText:self.showAlls],
                       [OTFeedItemFilter createFor:FeedItemFilterKeyPartners
                                            active:self.showPartners
                                          children:@[]
                                             image:@""
                                      showBoldText:self.showPartners]]];
    
    NSArray *timeframe =  @[
                            [OTFeedItemTimeframeFilter createFor:FeedItemFilterKeyTimeframe
                                                timeframeInHours:self.timeframeInHours]
                            ];
    [array addObject:timeframe];
    NSLog(@"***** return group public : %@",array);
    return array;
}

- (NSArray *)groupForPro {
    // Tours section
    NSArray *tourChildren = @[[OTFeedItemFilter createFor:FeedItemFilterKeyMedical
                                                   active:self.showMedical
                                                withImage:@"filter_heal"],
                              [OTFeedItemFilter createFor:FeedItemFilterKeySocial
                                                   active:self.showSocial
                                                withImage:@"filter_social"],
                              [OTFeedItemFilter createFor:FeedItemFilterKeyDistributive
                                                   active:self.showDistributive
                                                withImage:@"filter_eat"]];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *tours = [[NSMutableArray alloc] initWithObjects:
                             [OTFeedItemFilter createFor:FeedItemFilterKeyTour
                                                  active:self.showTours
                                                children:tourChildren
                                            showBoldText:YES], nil];
    [tours addObjectsFromArray:tourChildren];

    if (!self.isVersionAlone) {
        [array addObject:tours];
    }
    
    if (self.isEncouterFilter) {
        if (self.isVersionAlone) {
            [array addObject:tours];
        }
        NSArray *timeframe =  @[
            [OTFeedItemTimeframeFilter createFor:FeedItemFilterKeyTimeframe
                                timeframeInHours:self.timeframeInHours]
        ];
        [array addObject:timeframe];
        return array;
    }
    
    // Events section
    if (!self.isVersionAlone) {
        [array addObject:[self groupEntourageEvents]];
    }
   
    
    // Actions section
    [array addObject:[self groupActions]];
   // [array addObject:[self groupUniquement]];
    NSArray *timeframe =  @[
                            [OTFeedItemTimeframeFilter createFor:FeedItemFilterKeyTimeframe
                                                timeframeInHours:self.timeframeInHours]
                            ];
    [array addObject:timeframe];
    return array;
}

- (NSArray *)demandCategory: (OTCategoryType *)demande {
    NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
    int index = 6;
    for (OTCategory *category in demande.categories) {
        NSString *value = [NSString stringWithFormat:@"%@_%@", demande.type, category.category];
        [categoryArray addObject:[OTFeedItemFilter createFor:index
                                                      active:[[self.categoryDictionary valueForKey:value] boolValue]
                                                   withImage:value
                                                       title:category.title]];
        index++;
    }
    return categoryArray;
}

- (NSArray *)contributionCategory: (OTCategoryType *)contribution {
    NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
    int index = 0;
    for (OTCategory *category in contribution.categories) {
        NSString *value = [NSString stringWithFormat:@"%@_%@", contribution.type, category.category];
        [categoryArray addObject:[OTFeedItemFilter createFor:index
                                                      active:[[self.categoryDictionary valueForKey:value] boolValue]
                                                   withImage:value
                                                       title:category.title]];
        index++;
    }
    return categoryArray;
}

- (NSArray *)groupActions {
    NSArray *data = [OTCategoryFromJsonService getData];
    NSMutableArray *action = [[NSMutableArray alloc] init];
    OTCategoryType *contribution = nil;
    OTCategoryType *demande = nil;
    
    for (OTCategoryType *type in data) {
        if ([type.type isEqualToString:@"contribution"]) {
            contribution = type;
        }
        else if ([type.type isEqualToString:@"ask_for_help"]) {
            demande = type;
        }
    }
    NSArray *contributionArray = [self contributionCategory:contribution];
    NSArray *demandeArray = [self demandCategory:demande];
    [action addObject: [OTFeedItemFilter createFor:FeedItemFilterKeyDemand
                                            active:[[self.categoryDictionary valueForKey:demande.type] boolValue]
                                          children:demandeArray
                                      showBoldText:YES]];
    [action addObjectsFromArray:demandeArray];
    [action addObject: [OTFeedItemFilter createFor:FeedItemFilterKeyContribution
                                            active:[[self.categoryDictionary valueForKey:contribution.type] boolValue]
                                          children:contributionArray
                                      showBoldText:YES]];
    [action addObjectsFromArray:contributionArray];
    
    NSLog(@"***** return group action %@",action);
    return action;
}

- (NSArray *)groupUniquement {
    OTUser *user = [NSUserDefaults standardUserDefaults].currentUser;
    NSArray *uniquement = nil;
    if (user.partner == nil)
        uniquement = @[
                       [OTFeedItemFilter createFor:FeedItemFilterKeyMyEntourages
                                            active:self.showOnlyMyEntourages
                                          children:@[]]
                       ];
    else
        uniquement = @[
                       [OTFeedItemFilter createFor:FeedItemFilterKeyMyEntourages
                                            active:self.showOnlyMyEntourages
                                          children:@[]],
                       [OTFeedItemFilter createFor:FeedItemFilterKeyOrganisation
                                            active:self.showFromOrganisation
                                          children:@[]],
                       ];
    return uniquement;
}

- (NSArray *)groupEntourageEvents {
    NSArray *events = nil;
    events = @[
               [OTFeedItemFilter createFor:FeedItemFilterKeyEvents
                                     active:self.showOuting
                                   children:@[]
                                      image:@"ask_for_help_event"
                               showBoldText:YES],
               ];

    return events;
}
    
- (NSMutableDictionary *)toDictionaryWithBefore:(NSDate *)before
                                    andLocation:(CLLocationCoordinate2D)location {
    NSString *announces = self.isVersionAlone ? @"null" : @"v1";
    
    return @{
             @"before" : before,
             @"latitude": @(location.latitude),
             @"longitude": @(location.longitude),
             @"distance": @(self.distance),
             @"types" : [self getTypes],
             @"show_past_events" : self.showPastOuting ? @"true" : @"false",
             @"time_range" : @(self.timeframeInHours),
             @"announcements" : announces,
             @"partners_only" : self.showPartners ? @"true" : @"false"
    }.mutableCopy;
}

- (NSMutableDictionary *)toDictionaryWithPageToken:(NSString *)pageToken
                                    andLocation:(CLLocationCoordinate2D)location {
    
    NSString *announces = self.isEncouterFilter ? @"null" : @"v1";
    
    if (self.isVersionAlone) {
        announces = @"null";
    }
    if (self.isAnnouncementOnly) {
        return @{
                 @"latitude": @(location.latitude),
                 @"longitude": @(location.longitude),
                 @"types" : [self getTypes],
                 @"announcements" : self.isEncouterFilter ? @"null" : @"v1",
        }.mutableCopy;
    }
    return @{
             @"page_token" : pageToken == nil ? @"" : pageToken,
             @"latitude": @(location.latitude),
             @"longitude": @(location.longitude),
             @"distance": @(self.distance),
             @"types" : [self getTypes],
             @"show_past_events" : self.showPastOuting ? @"true" : @"false",
             @"time_range" : @(self.timeframeInHours),
             @"announcements" : announces,
             @"partners_only" : self.showPartners ? @"true" : @"false"
    }.mutableCopy;
}

- (void)updateValue:(OTFeedItemFilter *)filter {
    
    switch (filter.key) {
        case FeedItemFilterKeyDemandeSocial:
            self.showDemandeSocial = filter.active;
            break;
        case FeedItemFilterKeyDemandeHelp:
            self.showDemandeHelp = filter.active;
            break;
        case FeedItemFilterKeyDemandeResource:
            self.showDemandeResource = filter.active;
            break;
        case FeedItemFilterKeyDemandeInfo:
            self.showDemandeInfo = filter.active;
            break;
        case FeedItemFilterKeyDemandeSkill:
            self.showDemandeSkill = filter.active;
            break;
        case FeedItemFilterKeyDemandeOther:
            self.showDemandeOther = filter.active;
            break;
            
        case FeedItemFilterKeyContributionSocial:
            self.showContributionSocial = filter.active;
            break;
        case FeedItemFilterKeyContributionResource:
            self.showContributionResource = filter.active;
            break;
        case FeedItemFilterKeyContributionInfo:
            self.showContributionInfo = filter.active;
            break;
        case FeedItemFilterKeyContributionHelp:
            self.showContributionHelp = filter.active;
            break;
        case FeedItemFilterKeyContributionSkill:
            self.showContributionSkill = filter.active;
            break;
        case FeedItemFilterKeyContributionOther:
            self.showContributionOther = filter.active;
            break;
            
        case FeedItemFilterKeyMedical:
            self.showMedical = filter.active;
            break;
        case FeedItemFilterKeySocial:
            self.showSocial = filter.active;
            break;
        case FeedItemFilterKeyDistributive:
            self.showDistributive = filter.active;
            break;
        case FeedItemFilterKeyDemand:
            self.showDemand = filter.active;
            break;
        case FeedItemFilterKeyContribution:
            self.showContribution = filter.active;
            break;
        case FeedItemFilterKeyTour:
            self.showTours = filter.active;
            break;
        case FeedItemFilterKeyTimeframe:
            self.timeframeInHours = ((OTFeedItemTimeframeFilter *)filter).timeframeInHours;
            break;
        case FeedItemFilterKeyMyEntourages:
            self.showOnlyMyEntourages = filter.active;
            break;
        case FeedItemFilterKeyOrganisation:
            self.showFromOrganisation = filter.active;
            break;
        
        case FeedItemFilterKeyEvents:
            self.showOuting = filter.active;
            break;
        case FeedItemFilterKeyEventsPast:
            self.showPastOuting = filter.active;
            break;
            
        case FeedItemFilterKeyPartners:
            self.showPartners = filter.active;
            break;
        case FeedItemFilterKeyAlls:
            self.showAlls = filter.active;
            break;
        default:
            break;
    }
}

- (void)changeFiltersForProOnly {
    self.showNeighborhood = NO;
    self.showPrivateCircle = NO;
    self.showOuting = NO;
    self.showPastOuting = NO;
    
    self.showMedical = YES;
    self.showSocial = YES;
    self.showDistributive = YES;
    self.showDemand = NO;
    self.showContribution = NO;
    self.showTours = YES;
    
    self.showDemandeSocial = NO;
    self.showDemandeHelp = NO;
    self.showDemandeResource = NO;
    self.showDemandeInfo = NO;
    self.showDemandeSkill = NO;
    self.showDemandeOther = NO;
    
    self.showContributionSocial = NO;
    self.showContributionHelp = NO;
    self.showContributionResource = NO;
    self.showContributionInfo = NO;
    self.showContributionSkill = NO;
    self.showContributionOther = NO;
    
    self.isEncouterFilter = YES;
}

-(void)setNeighbourFilters {
    self.isEncouterFilter = NO;
    self.showMedical = NO;
    self.showSocial = NO;
    self.showDistributive = NO;
    
    self.showNeighborhood = YES;
    self.showPrivateCircle = YES;
    
    if (self.isVersionAlone) {
        self.showOuting = NO;
    }
    else {
        self.showOuting = YES;
    }
    
    self.showPastOuting = NO;
    
    self.showDemand = YES;
    self.showContribution = NO;
    self.showTours = NO;
    
    self.showDemandeSocial = YES;
    self.showDemandeHelp = YES;
    self.showDemandeResource = YES;
    self.showDemandeInfo = YES;
    self.showDemandeSkill = YES;
    self.showDemandeOther = YES;
    
    self.showContributionSocial = NO;
    self.showContributionHelp = NO;
    self.showContributionResource = NO;
    self.showContributionInfo = NO;
    self.showContributionSkill = NO;
    self.showContributionOther = NO;
}

-(void)setAloneFilters {
    self.isEncouterFilter = NO;
    self.showMedical = NO;
    self.showSocial = NO;
    self.showDistributive = NO;
    
    self.showNeighborhood = YES;
    self.showPrivateCircle = YES;
    
    if (self.isVersionAlone) {
        self.showOuting = NO;
    }
    else {
        self.showOuting = YES;
    }
    
    self.showPastOuting = NO;
    
    self.showDemand = NO;
    self.showContribution = YES;
    self.showTours = NO;
    
    self.showDemandeSocial = NO;
    self.showDemandeHelp = NO;
    self.showDemandeResource = NO;
    self.showDemandeInfo = NO;
    self.showDemandeSkill = NO;
    self.showDemandeOther = NO;
    
    self.showContributionSocial = YES;
    self.showContributionHelp = YES;
    self.showContributionResource = YES;
    self.showContributionInfo = YES;
    self.showContributionSkill = YES;
    self.showContributionOther = YES;
}

-(BOOL) isDefaultFilters {
    BOOL isDefault = YES;
    if (!self.showContributionSocial || !self.showContributionHelp || !self.showContributionResource || !self.showContributionOther) {
        isDefault = NO;
    }
    if (!self.showDemandeSocial || !self.showDemandeHelp || !self.showDemandeResource ||  !self.showDemandeOther) {
           isDefault = NO;
       }
    NSLog(@"***** is version alone filters : ? %d --- pro ?%d",self.isVersionAlone,self.isPro);
    
    if (self.isVersionAlone) {
        
        if (!self.showDemand || !self.showContribution || self.timeframeInHours != 30 * 24) {
            isDefault = NO;
        }
    }
    else {
        if (!self.showDemand || !self.showContribution || !self.showOuting || self.timeframeInHours != 30 * 24) {
            isDefault = NO;
        }
    }
    
    
    if (self.isPro && !self.isVersionAlone) {
        if (!self.showMedical || !self.showSocial || !self.showDistributive || !self.showTours) {
            isDefault = NO;
        }
    }
    
    if (self.showPartners) {
        isDefault = NO;
    }
    
    return isDefault;
}

-(BOOL) isDefaultEncounterFilters {
    BOOL isDefault = YES;
    
    if (!self.showMedical || !self.showSocial || !self.showDistributive || !self.showTours || self.timeframeInHours != 30 * 24) {
        isDefault = NO;
    }
    
    return isDefault;
}

- (NSArray *)timeframes {
    return @[@(24), @(8*24), @(30*24)];
}

- (NSString *)description {
    NSString *_desc = [NSString stringWithFormat:@"%d|%d|%d|%d|%d|%d|%d|%d|%f|%f|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d| --- isAlls %d - partners %d", self.showMedical, self.showSocial, self.showDistributive,
            self.showDemand, self.showContribution, self.showTours,
            self.showOnlyMyEntourages, self.timeframeInHours,
            
            self.location.latitude, self.location.longitude, self.distance, self.showFromOrganisation,
            self.showDemandeSocial, self.showDemandeHelp, self.showDemandeResource, self.showDemandeInfo, self.showDemandeSkill, self.showDemandeOther,
            
            self.showContributionSocial, self.showContributionHelp, self.showContributionResource, self.showContributionInfo, self.showContributionSkill, self.showContributionOther,
            
            self.showOuting, self.showPrivateCircle, self.showNeighborhood,self.showAlls,self.showPartners];
    NSLog(@"***** filters -> %@ -- isVersionAlone %d",_desc,self.isVersionAlone);
    return _desc;
}

- (NSString *)getTourTypes {
    NSMutableArray *types = [NSMutableArray new];
    if (self.showMedical)
        [types addObject:OTLocalizedString(@"tour_type_medical")];
    if (self.showSocial)
        [types addObject:OTLocalizedString(@"tour_type_bare_hands")];
    if (self.showDistributive)
        [types addObject:OTLocalizedString(@"tour_type_alimentary")];
    if (self.showTours && IS_PRO_USER)
        return [types componentsJoinedByString:@","];
    return @"";
}

- (NSString *)getTypes {
    if (self.isAnnouncementOnly) {
        return @"an";
    }
    
    NSLog(@"***** ici get types isalone ? %d",self.isVersionAlone);
    NSMutableArray *types = [NSMutableArray new];
    if (!self.isVersionAlone) {
        if (self.showMedical)
            [types addObject:@"tm"];
        if (self.showSocial)
            [types addObject:@"tb"];
        if (self.showDistributive)
            [types addObject:@"ta"];
    }
    
    
    if (self.showDemandeSocial)
        [types addObject:@"as"];
    if (self.showDemandeHelp)
        [types addObject:@"am"];
    if (self.showDemandeResource)
        [types addObject:@"ar"];
    if (self.showDemandeInfo)
        [types addObject:@"ai"];
    if (self.showDemandeSkill)
        [types addObject:@"ak"];
    if (self.showDemandeOther)
        [types addObject:@"ao"];
    if (self.showContributionSocial)
        [types addObject:@"cs"];
    if (self.showContributionHelp)
        [types addObject:@"cm"];
    if (self.showContributionResource)
        [types addObject:@"cr"];
    if (self.showContributionInfo)
        [types addObject:@"ci"];
    if (self.showContributionSkill)
        [types addObject:@"ck"];
    if (self.showContributionOther)
        [types addObject:@"co"];
    
    if (self.showPrivateCircle)
        [types addObject:@"pc"];
    if (self.showNeighborhood)
        [types addObject:@"nh"];
    
    if (self.showOuting)
        [types addObject:@"ou"];
    
    return [types componentsJoinedByString:@","];
}

- (NSString *)getEntourageTypes {
    NSMutableArray *types = [NSMutableArray new];
    if (self.showDemand) {
        [types addObject:ENTOURAGE_DEMANDE];
    }
    
    if (self.showContribution) {
        [types addObject:ENTOURAGE_CONTRIBUTION];
    }
    
    return [types componentsJoinedByString:@","];
}

-(void)setAnnouncementOnly {
    self.isAnnouncementOnly = YES;
}
-(void)setVersionAlone {
    self.isVersionAlone = YES;
    NSLog(@"***** ici setversionAlone ");
    
    NSString *type = [self getTypes];
    NSLog(@"***** ici setversionAlone get types %@ ",type);
}

- (id)copyWithZone:(NSZone *)zone {
    OTNewsFeedsFilter *copy = [OTNewsFeedsFilter new];
    copy.showMedical = self.showMedical;
    copy.showSocial = self.showSocial;
    copy.showDistributive = self.showDistributive;
    copy.showDemand = self.showDemand;
    copy.showContribution = self.showContribution;
    copy.showTours = self.showTours;
    copy.showOnlyMyEntourages = self.showOnlyMyEntourages;
    copy.timeframeInHours = self.timeframeInHours;
    copy.location = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude);
    copy.distance = self.distance;
    copy.showFromOrganisation = self.showFromOrganisation;
    
    copy.showNeighborhood = self.showNeighborhood;
    copy.showPrivateCircle = self.showPrivateCircle;
    copy.showOuting = self.showOuting;
    copy.showPastOuting = self.showPastOuting;
    
    
    copy.showDemandeSocial = self.showDemandeSocial;
    copy.showDemandeHelp = self.showDemandeHelp;
    copy.showDemandeResource = self.showDemandeResource;
    copy.showDemandeInfo = self.showDemandeInfo;
    copy.showDemandeSkill = self.showDemandeSkill;
    copy.showDemandeOther = self.showDemandeOther;
    
    copy.showContributionSocial = self.showContributionSocial;
    copy.showContributionHelp = self.showContributionHelp;
    copy.showContributionResource = self.showContributionResource;
    copy.showContributionInfo = self.showContributionInfo;
    copy.showContributionSkill = self.showContributionSkill;
    copy.showContributionOther = self.showContributionOther;
    
    copy.isEncouterFilter = self.isEncouterFilter;
    copy.showPartners = self.showPartners;
    copy.showAlls = self.showAlls;
    copy.isAnnouncementOnly = self.isAnnouncementOnly;
    copy.isVersionAlone = self.isVersionAlone;
    return copy;
}

@end

