//
//  FilterViewController.h
//  ProTubeClone
//
//  Created by Hoang on 1/17/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FilterDelegate <NSObject>

@optional
- (void)filterDidCancel;
- (void)filterDidFinshed;

@end

@interface FilterViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<FilterDelegate> filterDelegate;
@property (weak, nonatomic) IBOutlet UITableView *filtetTableView;

- (IBAction)cancelSelectRegion:(id)sender;
- (IBAction)doneSelectRegion:(id)sender;

@end
