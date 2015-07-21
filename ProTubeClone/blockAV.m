//
//  blockAV.m
//  ProTubeClone
//
//  Created by Apple on 12/08/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import "blockAV.h"

@interface blockAV()
{
    void (^_block)(NSInteger);
}
@end

@implementation blockAV

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id) initWithTitle:(NSString *)title message:(NSString *)message block: (void (^)(NSInteger buttonIndex))block
   cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_AVAILABLE(10_6, 4_0)
{
    if (self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil])
    {
        _block = block;
    }
    return self;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _block(buttonIndex);
}

@end
