//
//  RegionTableViewController.h
//  ProTubeClone
//
//  Created by Hoang on 1/7/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RegionTableViewControllerDelegate <NSObject>

@optional
- (void)regionCancel;
- (void)regionFinshed;

@end
@interface RegionTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<RegionTableViewControllerDelegate> regionDelegate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarItem;

- (IBAction)cancelSelectRegion:(id)sender;
- (IBAction)doneSelectRegion:(id)sender;
@end
