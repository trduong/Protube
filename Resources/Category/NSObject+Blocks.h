//
//  NSObject+Blocks.h
//  SnapChat
//
//  Created by 大門和斗 on 2014/01/07.
//  Copyright (c) 2014年 Primeagain Inc. All rights reserved.
//

@interface NSObject (Blocks)

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;

@end
