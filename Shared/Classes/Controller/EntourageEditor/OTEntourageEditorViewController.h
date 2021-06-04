//
//  OTEntourageEditorViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 10/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTEntourage.h"

@protocol EntourageEditorDelegate <NSObject>

- (void)didEditEntourage:(OTEntourage *)entourage;

@end

@interface OTEntourageEditorViewController : UIViewController

@property (nonatomic, strong) OTEntourage *entourage;
@property (nonatomic, weak) id<EntourageEditorDelegate> entourageEditorDelegate;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic) BOOL isEditingEvent;
@property (nonatomic) BOOL isAskForHelp;
@property (nonatomic) BOOL isFromHomeNeo;
@property(nonatomic,retain) NSString *tagNameAnalytic;
@end
