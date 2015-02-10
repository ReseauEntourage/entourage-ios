//
//  OTPlayerViewController.h
//  entourage
//
//  Created by Hugo Schouman on 27/01/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "OTAudioButton.h"


@interface OTPlayerView : UIView <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) IBOutlet OTAudioButton *audioButton;
@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UILabel *longueurLabel;

@property (nonatomic, strong) NSURL *recordedURL;
@property (nonatomic, strong) NSData *dowloadedFile;

@property (nonatomic, assign) BOOL isRecordingMode;

- (BOOL)hasRecordedFile;
- (void)stopPlaying;

@end
