//
//  CommentTableViewCell.h
//  ProTubeClone
//
//  Created by Apple on 12/09/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblAuthorName;
@property (strong, nonatomic) IBOutlet UILabel *lblPublishTime;
@property (strong, nonatomic) IBOutlet UITextView *tvContent;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *consHeightTv;
@end
