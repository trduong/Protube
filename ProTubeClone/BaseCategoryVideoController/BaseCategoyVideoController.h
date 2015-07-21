//
//  BaseCategoyVideoController.h
//  ProTubeClone
//
//  Created by Hoang on 1/16/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryVideo.h"
#import "Channel.h"
#import "PlaylistObject.h"
#import "AdViewController.h"

@class PlayListSearch;

@protocol BaseCategoryDelegate <NSObject>

@optional
- (void)loadNextPage;
- (void)categoryDidScroll:(UIScrollView*)scrollView;
- (void)categoryDidSelectVideo:(CategoryVideo*)video;
- (void)categoryDidSelectChanel:(Channel*)chanel;
- (void)baseCategoryDidSelectPlaylistItem:(PlaylistObject*)object;
- (void)categoryDidSelectPlayList:(PlayListSearch *)video;

@end

@interface BaseCategoyVideoController : AdViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) id<BaseCategoryDelegate> categoryDelegate;

@property (strong, nonatomic) UICollectionView              *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout    *collectionLayout;
@property (strong, nonatomic) UIActivityIndicatorView   *indicatorView;

@property (strong, nonatomic) NSMutableArray    *videosArray;
@property (assign, nonatomic) NSInteger         numberItems;
@property (strong, nonatomic) NSString          *nextPageToken;
@property (assign, nonatomic) BOOL isLoadingNextPage;
@property (assign, nonatomic) NSInteger currentPage;

@property (assign, nonatomic) BOOL isPageActivity;
@property (assign, nonatomic) BOOL isModeEdit;
@property (assign, nonatomic) BOOL isWhatLater;

// Resize postion for collection view
- (void)resizePostionCollectionViewWithRect:(CGRect)rect;
- (void)resizePostionActivityIndicatorView:(CGPoint)point;

// Start loading effect
- (void)startLoadingEffect;

// Stop loading effect
- (void)stopLoadingEffect;

@end
