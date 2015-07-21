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
@property (copy, nonatomic) void (^didDeleteVideoBlock)(id sender, NSIndexPath* indexPathCell);

@end

@implementation HomeCollectionViewCell

- (void)layoutSubviews
{
    [self.contentView addSubview:self.thumbnail];
    [self.contentView addSubview:self.durationLabel];
    [self.contentView addSubview:self.typeVideoLabel];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.userView];
    [self.contentView addSubview:self.subTitleLabel];
    [self.contentView addSubview:self.plusVideoButton];
    [self.contentView addSubview:self.deleteButton];
    
    self.layer.borderColor = [UIColor colorWithRed:207/255.0f green:207/255.0f blue:207/255.0f alpha:1.0f].CGColor;
    self.layer.borderWidth = 0.5f;
    
    [self.typeVideoLabel setHidden:YES];
    [self.deleteButton setHidden:YES];
    
    [super layoutSubviews];
}

#pragma mark Getters
- (UIImageView*)thumbnail
{
    if (!_thumbnail) {
        _thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, CGRectGetWidth(self.bounds) - 5.0f*2, 85.0f)];
        _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnail.clipsToBounds = YES;
        
        //[_thumbnail addSubview:self.durationLabel];
    }
    return _thumbnail;
}

- (UILabel*)typeVideoLabel
{
    if (!_typeVideoLabel) {
        _typeVideoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.thumbnail.frame), CGRectGetMinY(self.thumbnail.frame), 40.0f, 15.0f)];
        [_typeVideoLabel setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.6f]];
        [_typeVideoLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [_typeVideoLabel setTextAlignment:NSTextAlignmentCenter];
        [_typeVideoLabel setTextColor:[UIColor whiteColor]];
        [_typeVideoLabel setText:@"uploaded"];
        [_typeVideoLabel sizeToFit];
    }
    return _typeVideoLabel;
}

- (UILabel*)durationLabel
{
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.thumbnail.frame) - 40.0f, CGRectGetMaxY(self.thumbnail.frame) - 15.0f, 40.0f, 15.0f)];
        [_durationLabel setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.6f]];
        [_durationLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_durationLabel setTextAlignment:NSTextAlignmentCenter];
        [_durationLabel setTextColor:[UIColor grayColor]];
    }
    return _durationLabel;
}
- (UILabel*)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, CGRectGetMaxY(self.thumbnail.frame), CGRectGetWidth(self.thumbnail.frame), 30.0f)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setFont:[UIFont systemFontOfSize:11.0f]];
        _titleLabel.numberOfLines = 0;
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
    }
    return _userView;
}

- (UILabel*)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, CGRectGetMaxY(self.userView.frame), CGRectGetWidth(self.thumbnail.frame) - 25.0f, 15.0f)];
        [_subTitleLabel setBackgroundColor:[UIColor clearColor]];
        [_subTitleLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [_subTitleLabel setTextColor:[UIColor colorWithRed:211/255.0f green:211/255.0f blue:211/255.0f alpha:1.0f]];
    }
    return _subTitleLabel;
}

- (UIButton*)plusVideoButton
{
    if (!_plusVideoButton) {
        _plusVideoButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 22.0f, CGRectGetMinY(self.subTitleLabel.frame), 20.0f, 20.0f)];
        [_plusVideoButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        [_plusVideoButton addTarget:self action:@selector(clickedAddVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plusVideoButton;
}

- (UIButton*)deleteButton
{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.thumbnail.frame), CGRectGetMinY(self.thumbnail.frame) - 2.0f, 22.0f, 26.0f)];
        [_deleteButton setImage:[UIImage imageNamed:@"delete_x_button"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

#pragma mark Action
- (void)clickedAddVideo:(id)sender
{
    if (self.didAddVideoBlock) {
        self.didAddVideoBlock(sender, self.indexPathCell);
    }
}

- (void)deleteButtonPressed:(id)sender
{
    if (self.didDeleteVideoBlock) {
        self.didDeleteVideoBlock(sender, self.indexPathCell);
    }
}
@end
