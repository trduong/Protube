//
//  NSString+NumberChecking.m
//  ProTubeClone
//
//  Created by Hoang on 4/8/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "NSString+NumberChecking.h"

@implementation NSString (NumberChecking)

+ (BOOL)isNumber:(NSString*)string
{
    if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
        return YES;
    }
    return NO;
}
@end
