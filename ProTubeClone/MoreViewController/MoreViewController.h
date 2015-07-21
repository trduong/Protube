//
//  MoreViewController.h
//  ProTubeClone
//
//  Created by Hoang on 1/28/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdViewController.h"

@interface MoreViewController : AdViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView    *moreTableView;

@end
