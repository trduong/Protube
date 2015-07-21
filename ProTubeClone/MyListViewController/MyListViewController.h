//
//  MyListViewController.h
//  ProTubeClone
//
//  Created by Hoang on 1/26/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdViewController.h"

@interface MyListViewController : AdViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView    *myListTableView;

@end
