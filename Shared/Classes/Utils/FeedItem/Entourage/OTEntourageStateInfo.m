//
//  OTEntourageStateInfo.m
//  entourage
//
//  Created by sergiu buceac on 6/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageStateInfo.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTEntourageService.h"

@implementation OTEntourageStateInfo

- (FeedItemState)getState {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    FeedItemState result = FeedItemStateNone;
    if ([ENTOURAGE_STATUS_OPEN isEqualToString:self.entourage.status])
        result = FeedItemStateOpen;
    else
        return FeedItemStateClosed;
    if ([currentUser.sid intValue] != [self.entourage.author.uID intValue]) {
        if([JOIN_NOT_REQUESTED isEqualToString:self.entourage.joinStatus] || [JOIN_CANCELLED isEqualToString:self.entourage.joinStatus])
            result = FeedItemStateJoinNotRequested;
        else if([JOIN_ACCEPTED isEqualToString:self.entourage.joinStatus])
            result = FeedItemStateJoinAccepted;
        else if([JOIN_PENDING isEqualToString:self.entourage.joinStatus])
            result = FeedItemStateJoinPending;
        else if([JOIN_REJECTED isEqualToString:self.entourage.joinStatus])
            result = FeedItemStateJoinRejected;
    }
    return result;
}

- (BOOL)canChangeEditState {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if ([currentUser.sid intValue] == [self.entourage.author.uID intValue]) {
        return ![self.entourage.status isEqualToString:FEEDITEM_STATUS_CLOSED];
    }
    else {
        return [self.entourage.joinStatus isEqualToString:JOIN_ACCEPTED];
    }
    
    return NO;
}

- (BOOL)canInvite {
    return YES;
}

- (BOOL)isActive {
    return [self.entourage.status isEqualToString:ENTOURAGE_STATUS_OPEN];
}

- (BOOL)isClosed {
    return [self.entourage.status isEqualToString:FEEDITEM_STATUS_CLOSED];
}

- (BOOL)isPublic {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if ([self.entourage.status isEqualToString:FEEDITEM_STATUS_CLOSED]) {
        if ([self.entourage.joinStatus isEqualToString:JOIN_ACCEPTED]) {
            return NO;
        } else if (self.entourage.author) {
            if ([currentUser.sid intValue] == [self.entourage.author.uID intValue]) {
                return NO;
            }
        }
        
        return YES;
    }
        
    return ![self.entourage.joinStatus isEqualToString:JOIN_ACCEPTED];
}

- (BOOL)canEdit {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    return [currentUser.sid intValue] == [self.entourage.author.uID intValue];
}

- (BOOL)canCancelJoinRequest {
    
    if ([self.entourage isPrivateCircle] || [self.entourage isNeighborhood]) {
        //EMA-2439
        return [self.entourage.joinStatus isEqualToString:JOIN_PENDING];;
    }
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if ([currentUser.sid intValue] != [self.entourage.author.uID intValue]) {
        return [self.entourage.joinStatus isEqualToString:JOIN_PENDING];
    }
    
    return NO;
}

- (void)loadWithSuccess:(void(^)(OTFeedItem *))success error:(void(^)(NSError *))failure {
    if (self.entourage.uuid) {
        [[OTEntourageService new] getEntourageWithStringId:self.entourage.uuid withSuccess:^(OTEntourage *entourage) {
            if(success)
                success(entourage);
        } failure:^(NSError *error) {
            if(failure)
                failure(error);
        }];
    } else if (self.entourage.uid) {
        [[OTEntourageService new] getEntourageWithId:self.entourage.uid withSuccess:^(OTEntourage *entourage) {
            if(success)
                success(entourage);
        } failure:^(NSError *error) {
            if(failure)
                failure(error);
        }];
    } else {
        NSLog(@"Invalid entourage id!");
    }
}

- (void)loadWithSuccess2:(void(^)(OTFeedItem *))success error:(void(^)(NSError *))failure {
    [[OTEntourageService new] getEntourageWithStringId:self.entourage.fid withSuccess:^(OTEntourage *entourage) {
        if(success)
            success(entourage);
    } failure:^(NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)loadWithSuccess3:(void(^)(OTFeedItem *))success error:(void(^)(NSError *))failure {
    [[OTEntourageService new] getEntourageWithId:self.entourage.uid withSuccess:^(OTEntourage *entourage) {
        if(success)
            success(entourage);
    } failure:^(NSError *error) {
        if(failure)
            failure(error);
    }];
}

@end
