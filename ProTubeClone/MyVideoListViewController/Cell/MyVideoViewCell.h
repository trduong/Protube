//
//  MyVideoViewCell.h
//  ProTubeClone
//
//  Created by Hoang on 1/30/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyVideoViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView    *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel        *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel        *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel        *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel        *countLabel;

@end
