//
//  MenuItemViewCell.m
//  ProTubeClone
//
//  Created by Hoang on 2/10/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "MenuItemViewCell.h"

@implementation MenuItemViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.textLabel setTextColor:[UIColor colorWithRed:179/255.0f green:179/255.0f blue:179/255.0f alpha:1.0f]];
        [self.contentView setBackgroundColor:[UIColor colorWithRed:32/255.0f green:32/255.0f blue:32/255.0f alpha:1.0f]];
        //[self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self.textLabel setFont:[UIFont systemFontOfSize:15.0f]];
        
        self.imageView.clipsToBounds = YES;
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
//    CGRect rectView = self.selectedBackgroundView.frame;
//    rectView.origin.x = 9.0f;
//    self.selectedBackgroundView.frame = rectView;
}

- (void)layoutSubviews
{
    CGRect rect = self.imageView.frame;
    rect.origin.x = 10.0f;
    rect.size.height = CGRectGetHeight(self.bounds) - 50.0f;
    rect.size.width = rect.size.height;
    self.imageView.frame = rect;
    
    rect = self.textLabel.frame;
    rect.origin.x = CGRectGetMaxX(self.imageView.frame) + 10.0f;
    self.textLabel.frame = rect;
    
    self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    self.imageView.layer.borderWidth = 1.0f;
    self.imageView.layer.cornerRadius = 5.0f;
    
    if (self.needResizeImageView) {
        // resize image
        UIImage *icon = self.imageView.image;
        
        UIGraphicsBeginImageContext( CGSizeMake(35, 35) );
        
        [icon drawInRect:CGRectMake(0,0,35,35)];
        
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.imageView setImage:newImage];
        [self.imageView setAlpha:0.8];
    }
    
    [super layoutSubviews];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        [self.textLabel setTextColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
    } else {
        [self.textLabel setTextColor:[UIColor colorWithRed:179/255.0f green:179/255.0f blue:179/255.0f alpha:1.0f]];
    }
    // Configure the view for the selected state
}

//- (UIView*)backgroundViewSelected
//{
//    if (!_backgroundViewSelected) {
//        _backgroundViewSelected = [[UIView alloc] initWithFrame:CGRectMake(9.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
//        [_backgroundViewSelected setBackgroundColor:[UIColor colorWithRed:23/255.0f green:23/255.0f blue:23/255.0f alpha:1.0f]];
//    }
//    return _backgroundViewSelected;
//}

@end
