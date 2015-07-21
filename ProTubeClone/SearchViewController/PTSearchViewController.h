//
//  PTSearchViewController.h
//  ProTubeClone
//
//  Created by Hoang on 1/16/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCategoyVideoController.h"

@interface PTSearchViewController : BaseCategoyVideoController<UISearchBarDelegate, BaseCategoryDelegate>

@property (weak, nonatomic) IBOutlet UIView      *menuBarView;

@end
