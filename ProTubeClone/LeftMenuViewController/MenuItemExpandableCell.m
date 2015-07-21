//
//  MenuItemExpandableCell.m
//  ProTubeClone
//
//  Created by Hoang on 2/10/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "MenuItemExpandableCell.h"

@interface MenuItemExpandableCell()

@property (strong, nonatomic) UIView *separateLine;

@end
@implementation MenuItemExpandableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //[self _updateDetailTextLabel];
        [self.textLabel setTextColor:[UIColor colorWithRed:179/255.0f green:179/255.0f blue:179/255.0f alpha:1.0f]];
        self.backgroundColor = [UIColor colorWithRed:33/255.0f green:33/255.0f blue:33/255.0f alpha:1.0f];
        
        [self.textLabel setFont:[UIFont systemFontOfSize:13.0f]];
        
        [self.contentView addSubview:self.separateLine];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGRect rectText = self.textLabel.frame;
    rectText.origin.x = 4.0f;
    self.textLabel.frame = rectText;
    
    rect = self.separateLine.frame;
    rect.origin.y = CGRectGetHeight(self.bounds) - 0.5f;
    self.separateLine.frame = rect;

}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (NSString *)accessibilityLabel
{
    return self.textLabel.text;
}

- (void)setLoading:(BOOL)loading
{
    if (loading != _loading) {
        _loading = loading;
        [self _updateDetailTextLabel];
    }
}

- (void)setExpansionStyle:(UIExpansionStyle)expansionStyle animated:(BOOL)animated
{
    if (expansionStyle != _expansionStyle) {
        _expansionStyle = expansionStyle;
        //[self _updateDetailTextLabel];
    }
}

- (void)_updateDetailTextLabel
{
    if (self.isLoading) {
        self.detailTextLabel.text = @"Loading data";
    } else {
        switch (self.expansionStyle) {
            case UIExpansionStyleExpanded:
                self.detailTextLabel.text = @"Click to collapse";
                break;
            case UIExpansionStyleCollapsed:
                self.detailTextLabel.text = @"Click to expand";
                break;
        }
    }
}

#pragma mark
- (UIView*)separateLine
{
    if (!_separateLine) {
        _separateLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.bounds) - 0.5f, CGRectGetWidth(self.bounds), 0.5f)];
        [_separateLine setBackgroundColor:[UIColor colorWithRed:179/255.0f green:179/255.0f blue:179/255.0f alpha:1.0f]];
    }
    return _separateLine;
}
@end
