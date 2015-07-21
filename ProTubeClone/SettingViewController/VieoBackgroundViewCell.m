//
//  VieoBackgroundViewCell.m
//  ProTubeClone
//
//  Created by Hoang on 3/20/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "VieoBackgroundViewCell.h"

@implementation VieoBackgroundViewCell

@synthesize titleLabel;
@synthesize buttonSwitch;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = buttonSwitch.frame;
    rect.origin.x = CGRectGetWidth(self.frame) - CGRectGetWidth(rect) - 15.0f;
    buttonSwitch.frame = rect;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
