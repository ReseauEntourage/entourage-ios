//
//  OTDistributedDelegateBehavior.m
//  entourage
//
//  Created by sergiu buceac on 10/2/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTDistributedDelegateBehavior.h"

@implementation OTDistributedDelegateBehavior

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector])
        return YES;
    for(id delegate in self.delegates)
        if ([delegate respondsToSelector:aSelector])
            return YES;
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];
    if (!signature)
        for(NSObject *delegate in self.delegates)
            if ([delegate respondsToSelector:aSelector])
                return [delegate methodSignatureForSelector:aSelector];
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    for(NSObject *delegate in self.delegates)
        if ([delegate respondsToSelector:[anInvocation selector]])
            [anInvocation invokeWithTarget:delegate];
}

@end
