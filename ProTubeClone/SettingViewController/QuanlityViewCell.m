//
//  QuanlityViewCell.m
//  ProTubeClone
//
//  Created by Hoang on 3/10/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "QuanlityViewCell.h"

@implementation QuanlityViewCell

@synthesize txtLabel;
@synthesize titleLabel;

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = txtLabel.frame;
    rect.origin.x = CGRectGetWidth(self.frame) - CGRectGetWidth(rect) - 15.0f;
    txtLabel.frame = rect;
    
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
