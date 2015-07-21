//
//  ChannelCollectionViewCell.h
//  ProTubeClone
//
//  Created by Hoang on 1/20/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView   *thumbnail;
@property (strong, nonatomic) UILabel       *numberVideosLabel;
@property (strong, nonatomic) UILabel       *titleLabel;
@property (strong, nonatomic) UILabel       *subcriberLabel;

@property (weak, nonatomic) NSIndexPath *indexPathCell;

@end
