//
//  SignoutExpandableCell.h
//  ProTubeClone
//
//  Created by Hoang on 2/11/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLExpandableTableView.h"

@interface SignoutExpandableCell : UITableViewCell<UIExpandingTableViewCell>

@property (nonatomic, assign, getter = isLoading) BOOL loading;

@property (nonatomic, readonly) UIExpansionStyle expansionStyle;

@property (strong, nonatomic) UIImageView * userImageView;
@property (strong, nonatomic) UILabel     * userNameLabel;
@property (strong, nonatomic) UILabel     * emailLabel;
@property (strong, nonatomic) UIButton    * signOutButton;

- (void)setExpansionStyle:(UIExpansionStyle)expansionStyle animated:(BOOL)animated;

- (void)setDidSelectSignOutBlock:(void (^)(id sender))didSelectSignOutBlock;

@end
