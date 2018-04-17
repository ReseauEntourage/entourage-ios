//
//  MKMapView+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 28/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "MKMapView+entourage.h"

@implementation MKMapView (entourage)

- (void)takeSnapshotToFile:(NSString *)snapshotName {
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    MKCoordinateRegion region = self.region;
    region.span = MKCoordinateSpanMake(MIN(region.span.latitudeDelta, region.span.longitudeDelta),
                                       MIN(region.span.latitudeDelta, region.span.longitudeDelta));
    options.region = region;
    options.size =  CGSizeMake(MIN(self.frame.size.width, self.frame.size.height),
                               MIN(self.frame.size.width, self.frame.size.height));
    options.scale = [[UIScreen mainScreen] scale];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:snapshotName];
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        if (error) {
            NSLog(@"[Error] %@", error);
            return;
        }
        
        UIImage *image = snapshot.image;
        
        ////////////////////////////////////////////////////////////////////////
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        {
            for (id polyline in self.overlays) {
                if ([polyline isKindOfClass:[MKPolyline class]]) {
                    [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
                    
                    CGContextRef c = UIGraphicsGetCurrentContext();
                    MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyline];
                    if (polylineRenderer.path) {
                        [polylineRenderer applyStrokePropertiesToContext:c atZoomScale:1.0f];
                        CGContextAddPath(c, polylineRenderer.path);
                        CGContextStrokePath(c);
                    }
                }
            }
        }
        UIGraphicsEndImageContext();
        ////////////////////////////////////////////////////////////////////////
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:filePath atomically:YES];
    }];
    NSLog(@"Saved map snapshot to %@", snapshotName);
}

@end
