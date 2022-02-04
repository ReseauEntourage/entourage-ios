//
//  OTMapDelegateProxyBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/30/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTMapDelegateProxyBehavior.h"

@interface OTMapDelegateProxyBehavior () <MKMapViewDelegate>

@end

@implementation OTMapDelegateProxyBehavior

- (void)initialize {
    self.mapView.delegate = self;
}

#pragma mark - MKMapViewDelegate

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector])
        return YES;
    for(id delegate in _delegates)
        if ([delegate respondsToSelector:aSelector])
            return YES;
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];
    if (!signature)
        for(OTMapDelegateBehavior *delegate in self.delegates)
            if ([delegate respondsToSelector:aSelector])
                return [delegate methodSignatureForSelector:aSelector];
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    for(OTMapDelegateBehavior *delegate in self.delegates)
        if ([delegate respondsToSelector:[anInvocation selector]])
            [anInvocation invokeWithTarget:delegate];
}

@end
