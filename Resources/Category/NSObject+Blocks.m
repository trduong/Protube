//
//  NSObject+Blocks.m
//  SnapChat
//
//  Created by 大門和斗 on 2014/01/07.
//  Copyright (c) 2014年 Primeagain Inc. All rights reserved.
//

#import "NSObject+Blocks.h"

@implementation NSObject (Blocks)

- (void)performBlock:(void (^)())block
{
    block();
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    void (^block_)() = [block copy];
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}

@end
