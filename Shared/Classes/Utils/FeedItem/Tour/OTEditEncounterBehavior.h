//
//  OTEditEncounterBehavior.h
//  entourage
//
//  Created by veronica.gliga on 10/05/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTBehavior.h"
#import "OTEncounter.h"
#import <MapKit/MapKit.h>

#define kNotificationEncounterEdited @"NotificationEncounterEdited"
#define kNotificationEncounterEditedInfoKey @"NotificationEncounterEditedInfoKey"

@interface OTEditEncounterBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;

@property (nonatomic, strong, readwrite) OTEncounter *encounter;

- (void)doEdit:(OTEncounter *)encounter forTour:(NSNumber *)tourId andLocation:(CLLocationCoordinate2D) location;
- (BOOL)prepareSegue:(UIStoryboardSegue *)segue;

@end
