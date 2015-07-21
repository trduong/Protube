//
//  MyVideoViewCell.m
//  ProTubeClone
//
//  Created by Hoang on 1/30/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "MyVideoViewCell.h"

@implementation MyVideoViewCell

@synthesize thumbnailImageView;
@synthesize titleLabel;
@synthesize subTitleLabel;
@synthesize durationLabel;
@synthesize countLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = titleLabel.frame;
    rect.size.width = CGRectGetWidth(self.frame) - CGRectGetMinX(rect) - 25.0f;
    titleLabel.frame = rect;
    
    rect = subTitleLabel.frame;
    rect.size.width = CGRectGetWidth(self.frame) - CGRectGetMinX(rect) - 25.0f;
    subTitleLabel.frame = rect;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
