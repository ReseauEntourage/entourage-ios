//
//  OTCustomSegmentedBehavior.h
//  entourage
//
//  Created by sergiu.buceac on 04/04/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTBehavior.h"

@interface OTCustomSegmentedBehavior : OTBehavior

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *segments;
@property (nonatomic, weak) IBOutlet UIView *segmentedControl;

@property (nonatomic, assign) int selectedIndex;

- (void)updateVisible:(BOOL)visible;

- (IBAction)segmentTapped:(id)sender;

@end
