//
//  ChannelCollectionViewCell.m
//  ProTubeClone
//
//  Created by Hoang on 1/20/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "ChannelCollectionViewCell.h"

@implementation ChannelCollectionViewCell

- (void)layoutSubviews
{
    [self.contentView addSubview:self.thumbnail];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subcriberLabel];
    
    self.layer.borderColor = [UIColor colorWithRed:207/255.0f green:207/255.0f blue:207/255.0f alpha:1.0f].CGColor;
    self.layer.borderWidth = 0.5f;
    
    [super layoutSubviews];
}

#pragma mark Getters
- (UIImageView*)thumbnail
{
    if (!_thumbnail) {
        _thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, CGRectGetWidth(self.bounds) - 5.0f*2, 120.0f)];
        _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnail.clipsToBounds = YES;
        _thumbnail.image = [UIImage imageNamed:@"thumb"];
        
        [_thumbnail addSubview:self.numberVideosLabel];
    }
    return _thumbnail;
}

- (UILabel*)numberVideosLabel
{
    if (!_numberVideosLabel) {
        _numberVideosLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 100.0f, CGRectGetHeight(self.thumbnail.frame) - 15.0f, 100.0f, 15.0f)];
        [_numberVideosLabel setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.6f]];
        [_numberVideosLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_numberVideosLabel setTextAlignment:NSTextAlignmentCenter];
        [_numberVideosLabel setTextColor:[UIColor grayColor]];
        [_numberVideosLabel setText:@"100 videos"];
        
    }
    return _numberVideosLabel;
}

- (UILabel*)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, CGRectGetMaxY(self.thumbnail.frame) + 2.0f, CGRectGetWidth(self.frame) - 10.0f, 15.0f)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [_titleLabel setText:@"Hoang"];
    }
    return _titleLabel;
}

- (UILabel*)subcriberLabel
{
    if (!_subcriberLabel) {
        _subcriberLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, CGRectGetMaxY(self.titleLabel.frame), CGRectGetWidth(self.frame) - 10.0f, 15.0f)];
        [_subcriberLabel setBackgroundColor:[UIColor clearColor]];
        [_subcriberLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [_subcriberLabel setTextColor:[UIColor colorWithRed:211/255.0f green:211/255.0f blue:211/255.0f alpha:1.0f]];
        [_subcriberLabel setText:@"1,244 subcribers"];
    }
    return _subcriberLabel;
}
@end
