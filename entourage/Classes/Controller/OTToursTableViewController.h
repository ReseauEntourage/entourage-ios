//
//  OTToursTableViewController.h
//  entourage
//
//  Created by Nicolas Telera on 19/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTToursTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *tableData;

- (void)configureWithTours:(NSMutableArray *)closeTours;

@end
