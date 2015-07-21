//
//  HomeCollectionViewCell.m
//  ProTubeClone
//
//  Created by Hoang on 12/31/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import "HomeCollectionViewCell.h"

@interface HomeCollectionViewCell()

@property (copy, nonatomic) void (^didAddVideoBlock)(id sender, NSIndexPath* indexPathCell);

@end

@implementation HomeCollectionViewCell

- (void)layoutSubviews
{
    [self.contentView addSubview:self.thumbnail];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.userView];
    [self.contentView addSubview:self.subTitleLabel];
    [self.contentView addSubview:self.plusVideoButton];
    
    self.layer.borderColor = [UIColor colorWithRed:207/255.0f green:207/255.0f blue:207/255.0f alpha:1.0f].CGColor;
    self.layer.borderWidth = 0.5f;
    
    [super layoutSubviews];
}

#pragma mark Getters
- (UIImageView*)thumbnail
{
    if (!_thumbnail) {
        _thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, CGRectGetWidth(self.bounds) - 5.0f*2, 85.0f)];
        _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnail.clipsToBounds = YES;
        _thumbnail.image = [UIImage imageNamed:@"thumb"];
    }
    return _thumbnail;
}

- (UILabel*)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, CGRectGetMaxY(self.thumbnail.frame), CGRectGetWidth(self.thumbnail.frame), 30.0f)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
        _titleLabel.numberOfLines = 0;
        
        _titleLabel.text = @"How To Train Your Dragon 2: How It Should Have Ended";
    }
    return _titleLabel;
}

- (UILabel*)userView
{
    if (!_userView) {
        _userView = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, CGRectGetMaxY(self.titleLabel.frame), CGRectGetWidth(self.thumbnail.frame), 15.0f)];
        [_userView setBackgroundColor:[UIColor clearColor]];
        [_userView setTextColor:[UIColor colorWithRed:211/255.0f green:211/255.0f blue:211/255.0f alpha:1.0f]];
        [_userView setFont:[UIFont systemFontOfSize:11.0f]];
        
        _userView.text = @"244,882 views";
    }
    return _userView;
}

- (UILabel*)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, CGRectGetMaxY(self.userView.frame), CGRectGetWidth(self.thumbnail.frame) - 15.0f, 15.0f)];
        [_subTitleLabel setBackgroundColor:[UIColor clearColor]];
        [_subTitleLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [_subTitleLabel setTextColor:[UIColor colorWithRed:211/255.0f green:211/255.0f blue:211/255.0f alpha:1.0f]];
        [_subTitleLabel setText:@"How It Should Have Ended"];
    }
    return _subTitleLabel;
}

- (UIButton*)plusVideoButton
{
    if (!_plusVideoButton) {
        _plusVideoButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 5.0f - 13.0f, CGRectGetMinY(self.subTitleLabel.frame), 13.0f, 13.0f)];
        [_plusVideoButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        [_plusVideoButton addTarget:self action:@selector(clickedAddVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plusVideoButton;
}

#pragma mark Action
- (void)clickedAddVideo:(id)sender
{
    if (self.didAddVideoBlock) {
        self.didAddVideoBlock(sender, self.indexPathCell);
    }
}
@end
