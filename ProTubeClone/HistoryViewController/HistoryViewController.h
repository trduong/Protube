//
//  HistoryViewController.h
//  ProTubeClone
//
//  Created by Hoang on 1/30/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCategoyVideoController.h"

#import "PlaylistItem.h"

@interface HistoryViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView              *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout    *collectionLayout;

@property (nonatomic) BOOL isPlaylistItem;
@property (strong, nonatomic) PlaylistItem *playListItem;

- (void)loadPlaylistItemWithCategoryVideo:(PlaylistItem*)category;

@end
