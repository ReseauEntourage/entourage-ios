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

@end;

@implementation OTNewsFeedsFilter

- (instancetype)init {
    self = [super init];
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
            self.showDemandeEvent = !self.showDemand ? self.showDemand : savedFilter.showDemandeEvent.boolValue;
            self.showDemandeHelp = !self.showDemand ? self.showDemand : savedFilter.showDemandeHelp.boolValue;
            self.showDemandeResource = !self.showDemand ? self.showDemand : savedFilter.showDemandeResource.boolValue;
            self.showDemandeInfo = !self.showDemand ? self.showDemand : savedFilter.showDemandeInfo.boolValue;
            self.showDemandeSkill = !self.showDemand ? self.showDemand : savedFilter.showDemandeSkill.boolValue;
            self.showDemandeOther = !self.showDemand ? self.showDemand : savedFilter.showDemandeOther.boolValue;
            
            self.showContributionSocial = !self.showContribution ? self.showContribution : savedFilter.showContributionSocial.boolValue;
            self.showContributionEvent = !self.showContribution ? self.showContribution : savedFilter.showContributionEvent.boolValue;
            self.showContributionHelp = !self.showContribution ? self.showContribution : savedFilter.showContributionHelp.boolValue;
            self.showContributionResource = !self.showContribution ? self.showContribution : savedFilter.showContributionResource.boolValue;
            self.showContributionInfo = !self.showContribution ? self.showContribution : savedFilter.showContributionInfo.boolValue;
            self.showContributionSkill = !self.showContribution ? self.showContribution : savedFilter.showContributionSkill.boolValue;
            self.showContributionOther = !self.showContribution ? self.showContribution : savedFilter.showContributionOther.boolValue;
        }
        else {
            self.showNeighborhood = YES;
            self.showPrivateCircle = YES;
            self.showOuting = YES;
            self.showPastOuting = NO;
            
            self.showMedical = self.isPro;
            self.showSocial = self.isPro;
            self.showDistributive = self.isPro;
            self.showDemand = YES;
            self.showContribution = YES;
            self.showTours = self.isPro;
            self.showDemandeSocial = YES;
            self.showDemandeEvent = YES;
            self.showDemandeHelp = YES;
            self.showDemandeResource = YES;
            self.showDemandeInfo = YES;
            self.showDemandeSkill = YES;
            self.showDemandeOther = YES;
            self.showContributionSocial = YES;
            self.showContributionEvent = YES;
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
    
    if (OTAppConfiguration.applicationType == ApplicationTypeVoisinAge) {
        return @[
                 OTLocalizedString(@"filter_events_title"),
                 ];
    }
    
    if (IS_PRO_USER && OTAppConfiguration.supportsTourFunctionality)
        return @[
                 OTLocalizedString(@"filter_maraudes_title"),
                 OTLocalizedString(@"filter_events_title"),
                 OTLocalizedString(@"filter_entourages_title"),
                 OTLocalizedString(@"filter_entourage_from_sympathisants_title"),
                 OTLocalizedString(@"filter_timeframe_title")
                 ];
    else
        return @[
                 OTLocalizedString(@"filter_events_title"),
                 OTLocalizedString(@"filter_entourages_title"),
                 OTLocalizedString(@"filter_entourage_from_sympathisants_title"),
                 OTLocalizedString(@"filter_timeframe_title")
                 ];
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
                                 };
    
    if (OTAppConfiguration.applicationType == ApplicationTypeVoisinAge) {
        return [self groupForPfp];
    }
    
    if (IS_PRO_USER && OTAppConfiguration.supportsTourFunctionality) {
        return [self groupForPro];
    }
    else {
        return [self groupForPublic];
    }
}

- (NSArray *)parentArray {
    NSArray *data = [OTCategoryFromJsonService getData];
    NSMutableArray *parentArray = [[NSMutableArray alloc] init];
    
    if (IS_PRO_USER) {
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
    
    NSArray *eventChildren = @[[OTFeedItemFilter createFor:FeedItemFilterKeyEvents
                                                   active:self.showOuting
                                                withImage:@"ask_for_help_event"
                                                     title:@"filter_events_title"],
                              [OTFeedItemFilter createFor:FeedItemFilterKeyEventsPast
                                                   active:self.showPastOuting title:@"filter_events_include_past_events_title"]];
    
    [parentArray addObject:[OTFeedItemFilter createFor:FeedItemFilterKeyEvents
                                                active:self.showOuting
                                              children:eventChildren
                                                 image:@"ask_for_help_event"
                                          showBoldText:YES]];
    
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
    [array addObject:[self groupEntourageEvents]];
    
    [array addObject:[self groupActions]];
    [array addObject:[self groupUniquement]];
    NSArray *timeframe =  @[
                            [OTFeedItemTimeframeFilter createFor:FeedItemFilterKeyTimeframe
                                                timeframeInHours:self.timeframeInHours]
                            ];
    [array addObject:timeframe];
    return array;
}
    
- (NSArray *)groupForPfp {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    // Events section
    [array addObject:[self groupPfpEvents]];

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
    [array addObject:tours];
    
    // Events section
    [array addObject:[self groupEntourageEvents]];
    
    // Actions section
    [array addObject:[self groupActions]];
    [array addObject:[self groupUniquement]];
    NSArray *timeframe =  @[
                            [OTFeedItemTimeframeFilter createFor:FeedItemFilterKeyTimeframe
                                                timeframeInHours:self.timeframeInHours]
                            ];
    [array addObject:timeframe];
    return array;
}

- (NSArray *)demandCategory: (OTCategoryType *)demande {
    NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
    int index = 7;
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
    OTCategoryType *contribution;
    OTCategoryType *demande;
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
               [OTFeedItemFilter createFor:FeedItemFilterKeyEventsPast
                                    active:self.showPastOuting
                                  children:@[]],
               ];

    return events;
}
    
- (NSArray *)groupPfpEvents {
    NSArray *events = nil;
    events = @[
               [OTFeedItemFilter createFor:FeedItemFilterKeyEvents
                                    active:self.showOuting
                                  children:@[]
                                     image:@"ask_for_help_event"
                              showBoldText:YES],
               [OTFeedItemFilter createFor:FeedItemFilterKeyEventsPast
                                    active:self.showPastOuting
                                  children:@[]],
               ];
    
    return events;
}
    
- (NSMutableDictionary *)toDictionaryWithBefore:(NSDate *)before
                                    andLocation:(CLLocationCoordinate2D)location {
    return @{
             @"before" : before,
             @"latitude": @(location.latitude),
             @"longitude": @(location.longitude),
             @"distance": @(self.distance),
             @"types" : [self getTypes],
             @"show_my_entourages_only" : self.showOnlyMyEntourages ? @"true" : @"false",
             @"show_my_partner_only" : self.showFromOrganisation ? @"true" : @"false",
             @"show_past_events" : self.showPastOuting ? @"true" : @"false",
             @"time_range" : @(self.timeframeInHours),
             @"announcements" : @"v1"
    }.mutableCopy;
}

- (void)updateValue:(OTFeedItemFilter *)filter {
    switch (filter.key) {
        case FeedItemFilterKeyDemandeSocial:
            self.showDemandeSocial = filter.active;
            break;
        case FeedItemFilterKeyDemandeEvent:
            self.showDemandeEvent = filter.active;
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
        case FeedItemFilterKeyContributionEvent:
            self.showContributionEvent = filter.active;
            break;
        case FeedItemFilterKeyContributionHelp:
            self.showContributionHelp = filter.active;
            break;
        case FeedItemFilterKeyContributionInfo:
            self.showContributionInfo = filter.active;
            break;
        case FeedItemFilterKeyContributionResource:
            self.showContributionResource = filter.active;
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
        
        default:
            break;
    }
}

- (NSArray *)timeframes {
    return @[@(24), @(8*24), @(30*24)];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d|%d|%d|%d|%d|%d|%d|%d|%f|%f|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|", self.showMedical, self.showSocial, self.showDistributive,
            self.showDemand, self.showContribution, self.showTours,
            self.showOnlyMyEntourages, self.timeframeInHours,
            
            self.location.latitude, self.location.longitude, self.distance, self.showFromOrganisation,
            self.showDemandeSocial, self.showDemandeEvent, self.showDemandeHelp, self.showDemandeResource, self.showDemandeInfo, self.showDemandeSkill, self.showDemandeOther,
            
            self.showContributionSocial, self.showContributionEvent, self.showContributionHelp, self.showContributionResource, self.showContributionInfo, self.showContributionSkill, self.showContributionOther,
            
            self.showOuting];
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
    NSMutableArray *types = [NSMutableArray new];
    if (self.showMedical)
        [types addObject:@"tm"];
    if (self.showSocial)
        [types addObject:@"tb"];
    if (self.showDistributive)
        [types addObject:@"ta"];
    if (self.showDemandeSocial)
        [types addObject:@"as"];
    if (self.showDemandeEvent)
        [types addObject:@"ae"];
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
    if (self.showContributionEvent)
        [types addObject:@"ce"];
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
    if (self.showDemand)
        [types addObject:ENTOURAGE_DEMANDE];
    if (self.showContribution)
        [types addObject:ENTOURAGE_CONTRIBUTION];
    return [types componentsJoinedByString:@","];
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
    copy.showOnlyMyEntourages = self.showOnlyMyEntourages;
    copy.showFromOrganisation = self.showFromOrganisation;
    
    copy.showNeighborhood = self.showNeighborhood;
    copy.showPrivateCircle = self.showPrivateCircle;
    copy.showOuting = self.showOuting;
    self.showPastOuting = self.showPastOuting;
    
    return copy;
}

@end

