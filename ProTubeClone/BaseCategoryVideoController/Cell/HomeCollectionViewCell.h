//
//  HomeCollectionViewCell.h
//  ProTubeClone
//
//  Created by Hoang on 12/31/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView   *thumbnail;
@property (strong, nonatomic) UILabel       *typeVideoLabel;
@property (strong, nonatomic) UILabel       *durationLabel;
@property (strong, nonatomic) UILabel       *titleLabel;
@property (strong, nonatomic) UILabel       *userView;
@property (strong, nonatomic) UILabel       *subTitleLabel;
@property (strong, nonatomic) UIButton      *plusVideoButton;
@property (strong, nonatomic) UIButton      *deleteButton;

@property (weak, nonatomic) NSIndexPath *indexPathCell;

- (void)setDidAddVideoBlock:(void (^)(id sender, NSIndexPath* indexPathCell))didAddVideoBlock;
- (void)setDidDeleteVideoBlock:(void (^)(id sender, NSIndexPath* indexPathCell))didDeleteVideoBlock;

@end
