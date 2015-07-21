//
//  CommentTableViewCell.m
//  ProTubeClone
//
//  Created by Apple on 12/09/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame
{
    frame.origin.y += 10;
    frame.origin.x+=10;
    frame.size.width-=2*10;
    frame.size.height -=10;
    [super setFrame:frame];
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
}


@end
