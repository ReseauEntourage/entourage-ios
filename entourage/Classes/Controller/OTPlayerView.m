//
//  OTPlayerViewController.m
//  entourage
//
//  Created by Hugo Schouman on 27/01/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import "OTPlayerView.h"


@interface OTPlayerView ()

@property(nonatomic, strong) AVAudioRecorder *recorder;
@property(nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) NSTimer *recordingTimer;
@property(nonatomic, strong) NSTimer *playingTimer;

@end

@implementation OTPlayerView

/********************************************************************************/
#pragma mark - lifecycle

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self addSubview:
                [[[NSBundle mainBundle] loadNibNamed:@"OTPlayerView"
                                               owner:self
                                             options:nil] objectAtIndex:0]];

        [self.audioButton setRecordingState:RecordingButtonStateInit];
        [self.deleteButton setEnabled:NO];
    }
    return self;
}

/********************************************************************************/
#pragma mark - private methods

- (void)recordingTimerUpdate:(id)sender
{
    NSLog(@"%f %@", _recorder.currentTime, sender);
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%.2f", _recorder.currentTime];
}

- (void)playingTimerUpdate:(id)sender
{
    self.playTimeLabel.text = [NSString stringWithFormat:@"%.2f", _player.currentTime];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"did finish playing %d", flag);
    self.playTimeLabel.text = @"0.0";
    [self.playingTimer invalidate];
    self.playingTimer = nil;
    [self.deleteButton setEnabled:YES];
}

/********************************************************************************/
#pragma mark - actions

- (IBAction)recordDidTap:(UIButton *)sender
{
    if (self.audioButton.recordingState == RecordingButtonStateRecording)
    {
        [self stopRecord];
    }
    else if (self.audioButton.recordingState == RecordingButtonStateInit)
    {
        [self record];
    }
    else if (self.audioButton.recordingState == RecordingButtonStateRecorded)
    {
        [self play];
    }
}

- (void)stopRecord
{
    [self.recorder stop];
    [self.audioButton setRecordingState:RecordingButtonStateRecorded];
    [self.recordingTimer invalidate];
    self.recordingTimer = nil;
    NSLog(@"%@", self.recorder.url);
    [self.deleteButton setEnabled:YES];
}

- (void)record
{
    if ([self hasRecordedFile])
    {
        [self deleteCurrentRecordedFile];
    }

    [self.audioButton setRecordingState:RecordingButtonStateRecording];

    NSDictionary *recorderSettings = @{AVFormatIDKey : @(kAudioFormatAppleIMA4),
            AVSampleRateKey                          : @44100,
            AVNumberOfChannelsKey                    : @1,
            AVLinearPCMBitDepthKey                   : @16,
            AVLinearPCMIsBigEndianKey                : @NO,
            AVLinearPCMIsFloatKey                    : @NO};
    NSError *error = nil;
    self.recordedURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"]];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordedURL settings:recorderSettings error:&error];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    UInt32 doChangeDefault = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefault), &doChangeDefault);

    self.recorder.delegate = self;
    [self.recorder record];
    self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(recordingTimerUpdate:) userInfo:nil repeats:YES];
    [_recordingTimer fire];
}

- (void)play
{
//Play
    NSError *error = nil;
    [self.deleteButton setEnabled:NO];

    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:_recorder.url error:&error];
    _player.volume = 1.0f;
    _player.numberOfLoops = 0;
    _player.delegate = self;
    [_player play];
    self.playingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playingTimerUpdate:) userInfo:nil repeats:YES];
    [_playingTimer fire];
    NSLog(@"duration: %f", _player.duration);
}

- (IBAction)deleteButtonDidTap:(id)sender
{
    [self.audioButton setRecordingState:RecordingButtonStateInit];
    self.totalTimeLabel.text = @"0.0";
    self.playTimeLabel.text = @"0.0";
    [self deleteCurrentRecordedFile];
}

- (void)deleteCurrentRecordedFile
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"] error:&error];
    if (error != nil)
    {
        NSLog(@"ERROR deleting audio file : %@", error.description);
    }
    else
    {
        [self.deleteButton setEnabled:NO];
    }
}

/********************************************************************************/
#pragma mark - public methods

- (BOOL)hasRecordedFile
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"]];
}

@end
