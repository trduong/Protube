//
//  HomeViewController.h
//  ProTubeClone
//
//  Created by Hoang on 12/29/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCategoyVideoController.h"
#import <AFHTTPRequestOperationManager.h>

#import "MenuItem.h"

@protocol HomeDelegate <NSObject>

@optional
- (void)homeDidSelectVideo:(CategoryVideo*)video;
- (void)homeDidPressBackButton;

@end
@interface HomeViewController : BaseCategoyVideoController<BaseCategoryDelegate>

@property (weak, nonatomic) id<HomeDelegate> homeDelegate;

@property (assign, nonatomic) BOOL  showMenuBar;
@property (nonatomic) BOOL showFromSearch;

- (void)reloadVideo;
- (void)loadRelatedVideoWith:(NSString*)videoID;
- (void)loadContentWithItem:(MenuItem*)item;
- (void)loadVideos:(NSArray*)videos;


// Request api
- (void)requestActivityPart:(NSString*)part channelId:(NSString*)channelId maxResult:(NSInteger)maxResult pageToken:(NSString*)pageToken;

@end
