//
//  MyVideoListViewController.h
//  ProTubeClone
//
//  Created by Hoang on 1/30/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdViewController.h"

@interface MyVideoListViewController : AdViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView    *myVideoTableView;

@property (strong, nonatomic) NSString * txtTitle;

@end
