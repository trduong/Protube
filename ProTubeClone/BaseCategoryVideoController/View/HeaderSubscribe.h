//
//  HeaderSubscribe.h
//  ProTubeClone
//
//  Created by Hoang on 1/18/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuItem.h"

@interface HeaderSubscribe : UIView

@property (strong, nonatomic) UIImageView   *imageBackgroundView;
@property (strong, nonatomic) UIImageView   *avatarImageView;
@property (strong, nonatomic) UILabel       *userNameLabel;
@property (strong, nonatomic) UILabel       *subscriberLabel;
@property (strong, nonatomic) UIButton      *subcriberButton;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) UIViewController    *parentViewController;

@property (nonatomic) BOOL isSubscribe;
@property (strong, nonatomic) MenuItem * menuItem;

- (void)setDidSubcribeBlock:(void (^)(id sender))didSubcribeBlock;

@end
