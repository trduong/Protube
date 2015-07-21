//
//  MenuViewController.h
//  SlideMenu
//  Khanh
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLExpandableTableView.h"
#import <GooglePlus/GooglePlus.h>

#import "MenuItem.h"

@protocol LeftMenuDelegate <NSObject>

- (void)leftMenuDidSelectMenuItem:(MenuItem*)item;

@end
@interface LeftMenuViewController : UIViewController <GPPSignInDelegate, SLExpandableTableViewDatasource, SLExpandableTableViewDelegate>

@property (weak, nonatomic) id<LeftMenuDelegate> leftMenuDelegate;

@property (nonatomic, weak) IBOutlet SLExpandableTableView *tableView;
@property (nonatomic, assign) BOOL slideOutAnimationEnabled;

- (void)getContentItems;

@end
