//
//  RegionViewCell.m
//  ProTubeClone
//
//  Created by Hoang on 3/20/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "RegionViewCell.h"

@implementation RegionViewCell


- (void)layoutSubviews
{
    [self.contentView addSubview:self.nationImageView];
    [self.contentView addSubview:self.nationNameLabel];
    
    [super layoutSubviews];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark Getters
- (UIImageView*)nationImageView
{
    if (!_nationImageView) {
        _nationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0f, (CGRectGetHeight(self.frame) - 30.0f)/2, 30.0f, 30.0f)];
        [_nationImageView setClipsToBounds:YES];
    }
    return _nationImageView;
}

- (UILabel*)nationNameLabel
{
    if (!_nationNameLabel) {
        _nationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxY(self.nationImageView.frame) + 15.0f, 0.0f, 200.0f, CGRectGetHeight(self.frame))];
        [_nationNameLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [_nationNameLabel setTextColor:[UIColor blackColor]];
        
    }
    return _nationNameLabel;
}
@end
