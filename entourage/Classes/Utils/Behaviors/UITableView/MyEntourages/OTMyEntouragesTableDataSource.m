//
//  OTMyEntouragesTableDataSource.m
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesTableDataSource.h"
#import "OTMyEntouragesDataSource.h"
#import "OTTableCellProviderBehavior.h"
#import "OTFeedItem.h"

#define LOAD_MORE_DRAG_OFFSET 50

@interface OTMyEntouragesTableDataSource () <UITableViewDelegate>

@end

@implementation OTMyEntouragesTableDataSource

- (void)initialize {
    [super initialize];
    self.dataSource.tableView.delegate = self;
}

- (id)getItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource.items objectAtIndex:indexPath.section];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource.items count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellProvider getTableViewCellForPath:indexPath];
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = LOAD_MORE_DRAG_OFFSET;
    if(y > h + reload_distance) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [((OTMyEntouragesDataSource *)self.dataSource) loadNextPage];
        });
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [OTLogger logEvent:@"MessageOpen"];
    OTFeedItem *feedItem = (OTFeedItem *)[self getItemAtIndexPath:indexPath];
    [self.detailsBehavior showDetails:feedItem];
}

@end
