//
//  SignoutExpandableCell.m
//  ProTubeClone
//
//  Created by Hoang on 2/11/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "SignoutExpandableCell.h"

@interface SignoutExpandableCell()

@property (copy, nonatomic) void (^didSelectSignOutBlock)(id sender);

@end

@implementation SignoutExpandableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:33/255.0f green:33/255.0f blue:33/255.0f alpha:1.0f];
        
        [self.contentView addSubview:self.userImageView];
        [self.contentView addSubview:self.userNameLabel];
        [self.contentView addSubview:self.emailLabel];
        [self.contentView addSubview:self.signOutButton];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLoading:(BOOL)loading
{
    if (loading != _loading) {
        _loading = loading;
        //[self _updateDetailTextLabel];
    }
}

- (void)setExpansionStyle:(UIExpansionStyle)expansionStyle animated:(BOOL)animated
{
    if (expansionStyle != _expansionStyle) {
        _expansionStyle = expansionStyle;
        //[self _updateDetailTextLabel];
    }
}

#pragma mark Getters
- (UIImageView*)userImageView
{
    if (!_userImageView) {
        _userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0f, (CGRectGetHeight(self.bounds) - 34.0f)/2, 34.0f, 34.0f)];
        _userImageView.clipsToBounds = YES;
        _userImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _userImageView.layer.borderWidth = 1.0f;
        _userImageView.layer.cornerRadius = 5.0f;
        _userImageView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    return _userImageView;
}

- (UILabel*)userNameLabel
{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.userImageView.frame) + 12.0f, CGRectGetMinY(self.userImageView.frame), 200.0f, 17.0f)];
        [_userNameLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [_userNameLabel setTextColor:[UIColor whiteColor]];
    }
    return _userNameLabel;
}

- (UILabel*)emailLabel
{
    if (!_emailLabel) {
        _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.userImageView.frame) + 12.0f, CGRectGetMaxY(self.userNameLabel.frame), 200.0f, 17.0f)];
        [_emailLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [_emailLabel setTextColor:[UIColor colorWithRed:179/255.0f green:179/255.0f blue:179/255.0f alpha:1.0f]];
    }
    return _emailLabel;
}

- (UIButton*)signOutButton
{
    if (!_signOutButton) {
        _signOutButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - 26.0f - 12.0f - 60, (CGRectGetHeight(self.bounds) - 26.0f)/2, 26.0f, 26.0f)];
        [_signOutButton setImage:[UIImage imageNamed:@"signin"] forState:UIControlStateNormal];
        [_signOutButton addTarget:self action:@selector(signOutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signOutButton;
}

#pragma mark Button action
- (void)signOutButtonPressed:(id)sender
{
    if (self.didSelectSignOutBlock) {
        self.didSelectSignOutBlock(sender);
    }
}
@end
