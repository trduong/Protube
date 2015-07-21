//
//  AppDelegate.h
//  ProTubeClone
//
//  Created by Apple on 08/08/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Region.h"
#import "OrderFilter.h"
#import "PublishDateFilter.h"
#import "DurationFilter.h"
#import <GooglePlus/GooglePlus.h>

@class MainViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(strong,nonatomic) NSMutableArray *aryComents;
@property(assign) BOOL isSend;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MainViewController *viewController;
@property (strong, nonatomic) Region        *regionSelected;
@property (strong, nonatomic) NSIndexPath   *indexPathSelected;

@property (strong, nonatomic) OrderFilter       *orderFilter;
@property (strong, nonatomic) PublishDateFilter *publishFilter;
@property (strong, nonatomic) DurationFilter    *durationFilter;

@property (strong, nonatomic) UITabBarController *centerViewController;

@property (strong, nonatomic) NSString *playlistItems;

@property (strong, nonatomic) UIStoryboard  *storyBoard;


@end
