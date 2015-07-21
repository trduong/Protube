//
//  BaseCategoyVideoController.m
//  ProTubeClone
//
//  Created by Hoang on 1/16/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "BaseCategoyVideoController.h"
#import "AppDelegate.h"

#import "MyList.h"
#import "MyListPlay.h"
#import "PlayListSearch.h"
#import "ActivityObject.h"
#import "PlaylistObject.h"
#import "PlaylistItem.h"

#import "HomeCollectionViewCell.h"
#import "ChannelCollectionViewCell.h"
#import "UIImageView+WebCache.h"

#define HOME_CELL_IDENTIFIER        @"HOME_CELL_IDENTIFIER"
#define CHANNEL_CELL_IDENTIFIER     @"CHANNEL_CELL_IDENTIFIER"

@interface BaseCategoyVideoController ()<UIActionSheetDelegate>
{
    CategoryVideo *_categoryVideo;
}
@property (nonatomic) float startingOffset;
@property (nonatomic) NSMutableArray    *listPlayArray;

@end

@implementation BaseCategoyVideoController

@synthesize nextPageToken   = _nextPageToken;
@synthesize currentPage     = _currentPage;
@synthesize videosArray     = _videosArray;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayList:) name:NOTIFICATION_UPDATE_MY_LIST object:nil];
    
    self.listPlayArray = [[NSMutableArray alloc] init];
    [self fetchAllPlayList];
    
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _videosArray = [[NSMutableArray alloc] init];
    _nextPageToken = @"";
    _currentPage = 1;
    
    [self.view addSubview:self.collectionView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:self.collectionLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:HOME_CELL_IDENTIFIER];
        [_collectionView registerClass:[ChannelCollectionViewCell class] forCellWithReuseIdentifier:CHANNEL_CELL_IDENTIFIER];
        
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    }
    
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionLayout {
    if (!_collectionLayout) {
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        if(IS_IPAD){
            _collectionLayout.itemSize = CGSizeMake(CGRectGetWidth(self.view.frame)/3, 160.0f);
            _collectionLayout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 15.0f);
        } else {
            _collectionLayout.itemSize = CGSizeMake(CGRectGetWidth(self.view.frame)/2, 160.0f);
            _collectionLayout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 15.0f);
        }
        
        _collectionLayout.minimumInteritemSpacing = 0;
        _collectionLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        _collectionLayout.headerReferenceSize = CGSizeZero;
        _collectionLayout.footerReferenceSize = CGSizeMake(self.view.bounds.size.width, 50.0f);
    }
    return _collectionLayout;
}

- (UIActivityIndicatorView*)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds) - 50.0f)/2, 20.0f, 50.0f, 50.0f)];
        [_indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

#pragma mark Notification
- (void)updatePlayList:(NSNotification*)notification
{
    [self fetchAllPlayList];
}

#pragma mark Private methods
- (AppDelegate*)appDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void)fetchAllPlayList
{
    [[SACoreDataManament sharedCoreDataManament] fetchAllMyListWithCompletion:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            [self.listPlayArray removeAllObjects];
            
            for (MyList *entity in objects) {
                MyListPlay *list = [[MyListPlay alloc] init];
                list.nameList = entity.nameList;
                [self.listPlayArray addObject:list];
            }
        }
    }];
}

- (void)openPlayListVideos
{
    NSString *actionSheetTitle = @"Add to Playlist"; //Action Sheet Title
    NSString *cancelTitle = @"Cancel";
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:nil];
    
    for (MyListPlay *item in self.listPlayArray) {
        [actionSheet addButtonWithTitle:item.nameList];
    }
    [actionSheet addButtonWithTitle:@"New Playlist"];
    
    actionSheet.destructiveButtonIndex = self.listPlayArray.count + 1;
    
    [actionSheet showInView:self.view];
}

// Resize postion for collection view
- (void)resizePostionCollectionViewWithRect:(CGRect)rect;
{
    self.collectionView.frame = rect;
}

- (void)resizePostionActivityIndicatorView:(CGPoint)point
{
    CGRect rect = self.indicatorView.frame;
    rect.origin.y = point.y + 70.0f;
    rect.origin.x = point.x;
    self.indicatorView.frame = rect;
}

// Start loading effect
- (void)startLoadingEffect
{
    [self.view addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
}

// Stop loading effect
- (void)stopLoadingEffect
{
    [self.indicatorView stopAnimating];
    [self.indicatorView removeFromSuperview];
}

#pragma mark Config cell
- (HomeCollectionViewCell*)configHomeCell:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath
{
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HOME_CELL_IDENTIFIER forIndexPath:indexPath];
    
    // Set index path for cell
    cell.indexPathCell = indexPath;
    
    if (isSearching) {
        // Set data for cell
        if (gIndexTabSearch == 2) {
            PlayListSearch *playListSearch = [self.videosArray objectAtIndex:indexPath.row];
            Snippet *snippet = playListSearch.snippet;
            VideoThumbnail *thumbnail = snippet.highThumbnail;
            ContentDetails *contentDetails = playListSearch.contentDetails;
            
            cell.titleLabel.text = snippet.titleSnippet;
            cell.userView.text = [NSString stringWithFormat:@"%@ videos", [self formatNumberIntoDecimal:contentDetails.itemCount]];
            cell.subTitleLabel.text = snippet.channelTitle;
            [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:thumbnail.urlThumbnail] placeholderImage:nil];
            
            // Hidden
            [cell.durationLabel setHidden:YES];
            [cell.plusVideoButton setHidden:YES];
            
            //[self requestPlaylist:playListSearch cell:cell];
            
            if (!contentDetails) {
                [self requestPlaylist:playListSearch cell:cell];
            }
            
        } else {
            CategoryVideo *video = [self.videosArray objectAtIndex:indexPath.row];
            Snippet *snippet = video.snippet;
            Statistics *statistic = video.statistics;
            VideoThumbnail *thumbnail = snippet.highThumbnail;
            ContentDetails *contentDetails = video.contentDetails;
            
            cell.titleLabel.text = snippet.titleSnippet;
            cell.userView.text = [NSString stringWithFormat:@"%@ views", [self formatNumberIntoDecimal:statistic.viewCount]];
            cell.subTitleLabel.text = snippet.descriptionSnippet;
            [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:thumbnail.urlThumbnail] placeholderImage:nil];
            cell.durationLabel.text = [self parseISO8601Time:contentDetails.duration];
            
            // Display
            [cell.durationLabel setHidden:NO];
            [cell.plusVideoButton setHidden:NO];
            
            if (!statistic || !contentDetails) {
                [self requestVideoWithVideo:video cell:cell];
            } else {
                // Resize duration label
                [cell.durationLabel sizeToFit];
                CGRect rect = cell.durationLabel.frame;
                rect.size.width += 6.0f;
                rect.origin.x = CGRectGetWidth(cell.thumbnail.frame) - rect.size.width;
                cell.durationLabel.frame = rect;
            }
            
            [cell setDidAddVideoBlock:^(id sender, NSIndexPath *indexPathCell) {
                // Add video to a play list
                _categoryVideo = [self.videosArray objectAtIndex:indexPathCell.row];
                [self openPlayListVideos];
            }];
        }
        
    } else {
        if (isSelectedFromMenu && isSubscription) {
            switch (gIndexOfTabHome) {
                case 0: // Activity
                    [self loadDataActivitySubcriptionWithCell:cell atIndexPath:indexPath];
                    break;
                    
                case 1: // Videos
                    [self loadDataActivitySubcriptionWithCell:cell atIndexPath:indexPath];
                    break;
                    
                case 2: // Playlist
                    [self loadDataPlaylistSubcriptionWithCell:cell atIndexPath:indexPath];
                    break;
                    
                default:
                    abort();
                    break;
            }
        } else if(isSelectedFromMenu && isPlaylistItem){
            
            switch (numberOfPlaylistItem) {
                case 0: // Subcriptions
                    [self loadDataActivitySubcriptionWithCell:cell atIndexPath:indexPath];
                    break;
                    
                case 1: // What to Watch
                    [self loadDataPlaylistItemWithCell:cell atIndexPath:indexPath];
                    break;
                    
                case 2: // Favorite
                    
                    break;
                    
                case 3: // Watch late
                    [self loadDataPlaylistItemWithCell:cell atIndexPath:indexPath];
                    break;
                    
                case 4: // Playlist
                    [self loadDataPlaylistWithCell:cell atIndexPath:indexPath];
                    break;
                    
                    
                default:
                    break;
            }
            
        } else {
            // Set data for cell
            CategoryVideo *video = [self.videosArray objectAtIndex:indexPath.row];
            Snippet *snippet = video.snippet;
            Statistics *statistic = video.statistics;
            VideoThumbnail *thumbnail = snippet.highThumbnail;
            ContentDetails *contentDetails = video.contentDetails;
            
            cell.titleLabel.text = snippet.titleSnippet;
            cell.userView.text = [NSString stringWithFormat:@"%@ views", [self formatNumberIntoDecimal:statistic.viewCount]];
            cell.subTitleLabel.text = snippet.descriptionSnippet;
            [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:thumbnail.urlThumbnail] placeholderImage:nil];
            cell.durationLabel.text = [self parseISO8601Time:contentDetails.duration];
            
            // Display
            [cell.durationLabel setHidden:NO];
            [cell.plusVideoButton setHidden:NO];
            [cell.typeVideoLabel setHidden:YES];
            
            // Resize duration label
            [cell.durationLabel sizeToFit];
            CGRect rect = cell.durationLabel.frame;
            rect.size.width += 6.0f;
            rect.origin.x = CGRectGetWidth(cell.thumbnail.frame) - rect.size.width;
            cell.durationLabel.frame = rect;
            
            [cell setDidAddVideoBlock:^(id sender, NSIndexPath *indexPathCell) {
                // Add video to a play list
                _categoryVideo = [self.videosArray objectAtIndex:indexPathCell.row];
                [self openPlayListVideos];
            }];
        }
        
        
    }
    
    return cell;
}

#pragma mark - Load Data Subcription
- (void)loadDataActivitySubcriptionWithCell:(HomeCollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    ActivityObject *activity = [self.videosArray objectAtIndex:indexPath.row];
    Snippet *snippet = activity.snippet;
    VideoThumbnail *thumbnail = snippet.highThumbnail;
    
    [cell.deleteButton setHidden:YES];
    [cell.durationLabel setHidden:NO];
    [cell.plusVideoButton setHidden:NO];
    [cell.typeVideoLabel setHidden:NO];
    
    if (gIndexOfTabHome == 1) {
        [cell.typeVideoLabel setHidden:YES];
    }
    
    // Set data
    cell.titleLabel.text = snippet.titleSnippet;
    
    if (isSubscription) {
        if ([snippet.type isEqualToString:@"upload"]) {
            cell.typeVideoLabel.text = @"uploaded";
        } else {
            cell.typeVideoLabel.text = @"rated";
        }
        
        cell.subTitleLabel.text = snippet.descriptionSnippet;
    }
    
    if (isPlaylistItem) {
        [cell.typeVideoLabel setHidden:YES];
        cell.subTitleLabel.text = snippet.channelTitle;
    }
    
    
    if (!activity.isLoadedVideo) {
        // Load the video's info
        [self loadInfoVideoActivityWithCell:cell object:activity];
    } else {
        cell.userView.text = [NSString stringWithFormat:@"%@ views", [self formatNumberIntoDecimal:activity.statistics.viewCount]];
        cell.durationLabel.text = [self parseISO8601Time:activity.contentDetails.duration];
        
        // Resize numberVideosLabel
        [cell.durationLabel sizeToFit];
        CGRect rect = cell.durationLabel.frame;
        rect.size.width += 6.0f;
        rect.origin.x = CGRectGetMaxX(cell.thumbnail.frame) - rect.size.width;
        cell.durationLabel.frame = rect;
    }
    
    // Resize the type video label
    [cell.typeVideoLabel sizeToFit];
    CGRect rect = cell.typeVideoLabel.frame;
    rect.size.width = CGRectGetWidth(rect) + 5.0f;
    cell.typeVideoLabel.frame = rect;
    
    [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:thumbnail.urlThumbnail] placeholderImage:nil];
    
    cell.indexPathCell = indexPath;
    
    [cell setDidAddVideoBlock:^(id sender, NSIndexPath *indexPathCell) {
        _categoryVideo = [self.videosArray objectAtIndex:indexPathCell.row];
        [self openPlayListVideos];
    }];
}

- (void)loadInfoVideoActivityWithCell:(HomeCollectionViewCell*)cell object:(ActivityObject*)object
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSString *urlVideo=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics,contentDetails&id=%@&key=%@",object.contentDetails.videoUploadId, GOOGLE_KEY];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlVideo]
                                                                   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                               timeoutInterval:10];
            [request setHTTPMethod: @"GET"];
            NSError *error = nil;
            NSURLResponse *urlResponse = nil;
            NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
            id resultResponse = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
            
            if(!error){
                NSArray *items = resultResponse[@"items"];
                if (items) {
                    id videoResult = [items objectAtIndex:0];
                    
                    // Content details
                    object.contentDetails.duration = videoResult[@"contentDetails"][@"duration"];
                    
                    // Statistics
                    NSDictionary *statisticDict = videoResult[@"statistics"];
                    Statistics *statistics = [[Statistics alloc] init];
                    statistics.commentCount = [statisticDict[@"commentCount"] integerValue];
                    statistics.dislikeCount = [statisticDict[@"dislikeCount"] integerValue];
                    statistics.favoriteCount = [statisticDict[@"favoriteCount"] integerValue];
                    statistics.likeCount = [statisticDict[@"likeCount"] integerValue];
                    statistics.viewCount = [statisticDict[@"viewCount"] integerValue];
                    
                    object.statistics = statistics;
                    
                    // Load the info video finished.
                    object.isLoadedVideo = YES;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.userView.text = [NSString stringWithFormat:@"%@ views", [self formatNumberIntoDecimal:object.statistics.viewCount]];
                cell.durationLabel.text = [self parseISO8601Time:object.contentDetails.duration];
                
                // Resize numberVideosLabel
                [cell.durationLabel sizeToFit];
                CGRect rect = cell.durationLabel.frame;
                rect.size.width += 6.0f;
                rect.origin.x = CGRectGetMaxX(cell.thumbnail.frame) - rect.size.width;
                cell.durationLabel.frame = rect;
            });
        }
        @catch (NSException *exception) {
            
        }
    });
}

#pragma mark-
- (void)loadDataPlaylistSubcriptionWithCell:(HomeCollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    PlaylistObject *playlistObject = [self.videosArray objectAtIndex:indexPath.row];
    
    Snippet *snippet = playlistObject.snippet;
    //Statistics *statistic = activity.statistics;
    VideoThumbnail *thumbnail = snippet.highThumbnail;
    ContentDetails *contentDetails = playlistObject.contentDetails;
    
    [cell.typeVideoLabel setHidden:YES];
    [cell.plusVideoButton setHidden:YES];
    [cell.durationLabel setHidden:YES];
    
    // Set data
    cell.titleLabel.text = snippet.titleSnippet;
    cell.subTitleLabel.text = snippet.channelTitle;
    cell.userView.text = [NSString stringWithFormat:@"%@ videos", [self formatNumberIntoDecimal:contentDetails.itemCount]];
    [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:thumbnail.urlThumbnail] placeholderImage:[UIImage imageNamed:@"default_thumbnail"]];
}

#pragma mark - Load data playlist item
- (void)loadDataPlaylistItemWithCell:(HomeCollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    PlaylistItem *playlistItem = [self.videosArray objectAtIndex:indexPath.row];
    Snippet *snippet = playlistItem.snippet;
    VideoThumbnail *thumbnail = snippet.highThumbnail;
    Statistics *statistic = playlistItem.statistics;
    ContentDetails *content = playlistItem.contentDetails;
    
    [cell.deleteButton setHidden:YES];
    [cell.durationLabel setHidden:NO];
    [cell.typeVideoLabel setHidden:YES];
    [cell.plusVideoButton setHidden:NO];
    
    cell.titleLabel.text = snippet.titleSnippet;
    [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:thumbnail.urlThumbnail] placeholderImage:[UIImage imageNamed:@"default_thumbnail"]];
    cell.subTitleLabel.text = snippet.channelTitle;
    
    if (!self.isWhatLater) {
        // Set data
        cell.userView.text = [NSString stringWithFormat:@"%@ views", [self formatNumberIntoDecimal:statistic.videoCount]];
        
        cell.durationLabel.text = [self formatTimeFromSeconds:[content.duration intValue]];
        
        [cell.durationLabel sizeToFit];
        CGRect rect = cell.durationLabel.frame;
        rect.size.width += 6.0f;
        rect.origin.x = CGRectGetMaxX(cell.thumbnail.frame) - rect.size.width;
        cell.durationLabel.frame = rect;
    } else {
        if (!playlistItem.isLoadedVideo) {
            [self requestVideoWithVideo:playlistItem cell:cell];
        } else {
            cell.userView.text = [NSString stringWithFormat:@"%@ views", [self formatNumberIntoDecimal:playlistItem.statistics.viewCount]];
            cell.durationLabel.text = [self parseISO8601Time:playlistItem.contentDetails.duration];
            
            // Resize numberVideosLabel
            [cell.durationLabel sizeToFit];
            CGRect rect = cell.durationLabel.frame;
            rect.size.width += 6.0f;
            rect.origin.x = CGRectGetMaxX(cell.thumbnail.frame) - rect.size.width;
            cell.durationLabel.frame = rect;
        }
    }
    
    cell.indexPathCell = indexPath;
    [cell setDidAddVideoBlock:^(id sender, NSIndexPath *indexPathCell) {
        _categoryVideo = [self.videosArray objectAtIndex:indexPath.row];
        [self openPlayListVideos];
    }];
}

#pragma mark Playlist
- (void)loadDataPlaylistWithCell:(HomeCollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    PlaylistItem *playlistItem = [self.videosArray objectAtIndex:indexPath.row];
    Snippet *snippet = playlistItem.snippet;
    VideoThumbnail *thumbnail = snippet.highThumbnail;
    ContentDetails *contentDetail = playlistItem.contentDetails;
    
    [cell.durationLabel setHidden:YES];
    [cell.plusVideoButton setHidden:YES];
    
    if (self.isModeEdit) {
        [cell.deleteButton setHidden:NO];
    } else {
        [cell.deleteButton setHidden:YES];
    }
    
    // Set data
    cell.titleLabel.text = snippet.titleSnippet;
    cell.subTitleLabel.text = snippet.channelTitle;
    [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:thumbnail.urlThumbnail] placeholderImage:[UIImage imageNamed:@"default_thumbnail"]];
    cell.userView.text = [NSString stringWithFormat:@"%@ videos", [self formatNumberIntoDecimal:contentDetail.itemCount]];
    
    cell.indexPathCell = indexPath;
    
    [cell setDidDeleteVideoBlock:^(id sender, NSIndexPath *indexPathCell) {
        [self deletePlaylistItemAtIndexPath:indexPathCell];
    }];
}

// delete playlist item
- (void)deletePlaylistItemAtIndexPath:(NSIndexPath*)indexPath
{
    PlaylistItem *playlistItem = [self.videosArray objectAtIndex:indexPath.row];
    NSString *strToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[APIYoutubeManagement sharedAPIYoutubeManagement] deletePlaylistWithId:playlistItem.playlistId accessToken:strToken completion:^(id result, NSError *error) {
        if (!error) {
            
            [self.collectionView performBatchUpdates:^{
                [self.videosArray removeObjectAtIndex:indexPath.row];
                self.numberItems--;
                [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            } completion:^(BOOL finished) {
                [self.collectionView reloadData];
            }];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }];
}

-(NSString *)formatTimeFromSeconds:(int)numberOfSeconds
{
    int seconds = numberOfSeconds % 60;
    int minutes = (numberOfSeconds / 60) % 60;
    int hours = numberOfSeconds / 3600;

    if (hours) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes,seconds];
    }
    if (minutes) {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    
    return [NSString stringWithFormat:@"%02d", seconds];
}

#pragma mark Collection View Datasource
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        return header;
    }
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        return footer;
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.numberItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!isChannelView) {
        return [self configHomeCell:collectionView indexPath:indexPath];
    } else {
        if (!isActivityPage) {
            ChannelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CHANNEL_CELL_IDENTIFIER forIndexPath:indexPath];
            cell.indexPathCell = indexPath;
            
            // Set data for cell
            Channel *channel = [self.videosArray objectAtIndex:indexPath.row];
            Snippet *snippet = channel.snippet;
            Statistics *statistics = channel.statistics;
            VideoThumbnail *thumbnail = snippet.highThumbnail;
            
            [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:thumbnail.urlThumbnail] placeholderImage:nil];
            cell.titleLabel.text = snippet.titleSnippet;
            
            if (!statistics) {
                statistics = [[Statistics alloc] init];
                [self requestChannelWithChannel:channel statistics:statistics cell:cell];
            } else {
                cell.numberVideosLabel.text = [NSString stringWithFormat:@"%@ videos", [self formatNumberIntoDecimal:statistics.videoCount]];
                cell.subcriberLabel.text = [NSString stringWithFormat:@"%@ subcribers", [self formatNumberIntoDecimal:statistics.subscriberCount]];
                
                // Resize numberVideosLabel
                [cell.numberVideosLabel sizeToFit];
                CGRect rect = cell.numberVideosLabel.frame;
                rect.size.width += 6.0f;
                rect.origin.x = CGRectGetWidth(cell.thumbnail.frame) - rect.size.width;
                cell.numberVideosLabel.frame = rect;
            }
            
            return cell;
        } else {
            HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HOME_CELL_IDENTIFIER forIndexPath:indexPath];
            
            // Set index path for cell
            cell.indexPathCell = indexPath;
            
            // Set data
            ActivityObject *activity = [self.videosArray objectAtIndex:indexPath.row];
            Snippet *snippet = activity.snippet;
            Statistics *statistics = activity.statistics;
            VideoThumbnail *thumbnail = snippet.highThumbnail;
            
            cell.titleLabel.text = snippet.titleSnippet;
            cell.userView.text = [NSString stringWithFormat:@"%@ views", [self formatNumberIntoDecimal:statistics.viewCount]];
            cell.subTitleLabel.text = snippet.channelTitle;
            [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:thumbnail.urlThumbnail] placeholderImage:nil];
            
            if (!statistics) {
                [self requestVideoWithActivity:activity cell:cell];
            } else {
                // Resize numberVideosLabel
                [cell.durationLabel sizeToFit];
                CGRect rect = cell.durationLabel.frame;
                rect.size.width += 6.0f;
                rect.origin.x = CGRectGetWidth(cell.thumbnail.frame) - rect.size.width;
                cell.durationLabel.frame = rect;
            }
            return cell;
        }
    }
}

- (void)requestChannelWithChannel:(Channel*)channel statistics:(Statistics*)statistics cell:(ChannelCollectionViewCell*)cell
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Do background work
        @try {
            NSString *urlVideo=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/channels?part=snippet,statistics,contentDetails&id=%@&key=%@",channel.channelId, GOOGLE_KEY];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlVideo]
                                                                   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                               timeoutInterval:10];
            [request setHTTPMethod: @"GET"];
            NSError *error = nil;
            NSURLResponse *urlResponse = nil;
            NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
            id resultResponse = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
            
            if (!error) {
                NSArray *items = resultResponse[@"items"];
                if (items) {
                    id channelResult = [items objectAtIndex:0];
                    NSDictionary *statisticsDict = channelResult[@"statistics"];
                    
                    statistics.commentCount = [statisticsDict[@"commentCount"] integerValue];
                    statistics.hiddenSubscriberCount = [statisticsDict[@"hiddenSubscriberCount"] integerValue];
                    statistics.subscriberCount = [statisticsDict[@"subscriberCount"] integerValue];
                    statistics.videoCount = [statisticsDict[@"videoCount"] integerValue];
                    statistics.viewCount = [statisticsDict[@"viewCount"] integerValue];
                    
                    channel.statistics = statistics;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.numberVideosLabel.text = [NSString stringWithFormat:@"%@ videos", [self formatNumberIntoDecimal:statistics.videoCount]];
                cell.subcriberLabel.text = [NSString stringWithFormat:@"%@ subcribers", [self formatNumberIntoDecimal:statistics.subscriberCount]];
                
                // Resize numberVideosLabel
                [cell.numberVideosLabel sizeToFit];
                CGRect rect = cell.numberVideosLabel.frame;
                rect.size.width += 6.0f;
                rect.origin.x = CGRectGetWidth(cell.thumbnail.frame) - rect.size.width;
                cell.numberVideosLabel.frame = rect;
            });
        }
        @catch (NSException *exception) {
           // NSLog(@"%@", exception);
        }
       
        
    });
}

- (void)requestVideoWithVideo:(CategoryVideo*)categoryVideo cell:(HomeCollectionViewCell*)cell
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSString *urlVideo=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics,contentDetails&id=%@&key=%@",categoryVideo.videoId, GOOGLE_KEY];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlVideo]
                                                                   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                               timeoutInterval:10];
            [request setHTTPMethod: @"GET"];
            NSError *error = nil;
            NSURLResponse *urlResponse = nil;
            NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
            id resultResponse = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
            
            if(!error){
                NSArray *items = resultResponse[@"items"];
                if (items) {
                    id videoResult = [items objectAtIndex:0];
                    
                    // Content details
                    ContentDetails *contentDetails = [[ContentDetails alloc] init];
                    contentDetails.duration = videoResult[@"contentDetails"][@"duration"];
                    contentDetails.publishAt = videoResult[@"snippet"][@"publishedAt"];
                    categoryVideo.contentDetails = contentDetails;
                    
                    // Statistics
                    NSDictionary *statisticDict = videoResult[@"statistics"];
                    Statistics *statistics = [[Statistics alloc] init];
                    statistics.commentCount = [statisticDict[@"commentCount"] integerValue];
                    statistics.dislikeCount = [statisticDict[@"dislikeCount"] integerValue];
                    statistics.favoriteCount = [statisticDict[@"favoriteCount"] integerValue];
                    statistics.likeCount = [statisticDict[@"likeCount"] integerValue];
                    statistics.viewCount = [statisticDict[@"viewCount"] integerValue];
                    
                    categoryVideo.statistics = statistics;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.userView.text = [NSString stringWithFormat:@"%@ views", [self formatNumberIntoDecimal:categoryVideo.statistics.viewCount]];
                cell.durationLabel.text = [self parseISO8601Time:categoryVideo.contentDetails.duration];
                
                // Resize numberVideosLabel
                [cell.durationLabel sizeToFit];
                CGRect rect = cell.durationLabel.frame;
                rect.size.width += 6.0f;
                rect.origin.x = CGRectGetMaxX(cell.thumbnail.frame) - rect.size.width;
                cell.durationLabel.frame = rect;
            });
        }
        @catch (NSException *exception) {
            
        }
    });
}

- (void)requestVideoWithActivity:(ActivityObject*)activity cell:(HomeCollectionViewCell*)cell
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSString *urlVideo=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics,contentDetails&id=%@&key=%@",activity.contentDetails.videoUploadId, GOOGLE_KEY];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlVideo]
                                                                   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                               timeoutInterval:10];
            [request setHTTPMethod: @"GET"];
            NSError *error = nil;
            NSURLResponse *urlResponse = nil;
            NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
            id resultResponse = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
            
            if(!error){
                NSArray *items = resultResponse[@"items"];
                if (items) {
                    id videoResult = [items objectAtIndex:0];
                    
                    // Content details
                    activity.contentDetails.duration = videoResult[@"contentDetails"][@"duration"];
                    activity.snippet.titleSnippet = videoResult[@"snippet"][@"title"];
                    
                    // Statistics
                    NSDictionary *statisticDict = videoResult[@"statistics"];
                    Statistics *statistics = [[Statistics alloc] init];
                    statistics.commentCount = [statisticDict[@"commentCount"] integerValue];
                    statistics.dislikeCount = [statisticDict[@"dislikeCount"] integerValue];
                    statistics.favoriteCount = [statisticDict[@"favoriteCount"] integerValue];
                    statistics.likeCount = [statisticDict[@"likeCount"] integerValue];
                    statistics.viewCount = [statisticDict[@"viewCount"] integerValue];
                    
                    activity.statistics = statistics;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.titleLabel.text = activity.snippet.titleSnippet;
                cell.userView.text = [NSString stringWithFormat:@"%@ views", [self formatNumberIntoDecimal:activity.statistics.viewCount]];
                cell.durationLabel.text = [self parseISO8601Time:activity.contentDetails.duration];
                
                // Resize numberVideosLabel
                [cell.durationLabel sizeToFit];
                CGRect rect = cell.durationLabel.frame;
                rect.size.width += 6.0f;
                rect.origin.x = CGRectGetWidth(cell.thumbnail.frame) - rect.size.width;
                cell.durationLabel.frame = rect;
            });
        }
        @catch (NSException *exception) {
            
        }
    });
}

- (void)requestPlaylist:(PlayListSearch*)playList cell:(HomeCollectionViewCell*)cell
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSString *urlVideo=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlists?part=snippet,contentDetails&id=%@&key=%@",playList.playlistId, GOOGLE_KEY];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlVideo]
                                                                   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                               timeoutInterval:10];
            [request setHTTPMethod: @"GET"];
            NSError *error = nil;
            NSURLResponse *urlResponse = nil;
            NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
            id resultResponse = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
            
            if(!error){
                NSArray *items = resultResponse[@"items"];
                if (items) {
                    id videoResult = [items objectAtIndex:0];
                    
                    // Content details
                    ContentDetails *contentDetails = [[ContentDetails alloc] init];
                    contentDetails.itemCount = [videoResult[@"contentDetails"][@"itemCount"] integerValue];
                    playList.contentDetails = contentDetails;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.userView.text = [NSString stringWithFormat:@"%@ videos", [self formatNumberIntoDecimal:playList.contentDetails.itemCount]];
            });
        }
        @catch (NSException *exception) {
            
        }
    });
}

#pragma mark Collection view delegate
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    return CGSizeZero;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isChannelView) {
        if (gIndexOfTabHome == 2 && (gIndexTabbarItem == 0 || gIndexTabbarItem == 1)
            &&[[self.videosArray objectAtIndex:indexPath.row] isKindOfClass:[PlaylistObject class]]
            )
        {
            PlaylistObject *object = [self.videosArray objectAtIndex:indexPath.row];
            
            if ([self.categoryDelegate respondsToSelector:@selector(baseCategoryDidSelectPlaylistItem:)]) {
                [self.categoryDelegate baseCategoryDidSelectPlaylistItem:object];
            }
        } else {
            if ([self.categoryDelegate respondsToSelector:@selector(categoryDidSelectVideo:)]) {
                if ([[self.videosArray objectAtIndex:indexPath.row] isKindOfClass:[CategoryVideo class]]) {
                    CategoryVideo *video = [self.videosArray objectAtIndex:indexPath.row];
                    video.isHomeVideo = YES;
                    [self.categoryDelegate categoryDidSelectVideo:video];

                }
                else
                    if ([[self.videosArray objectAtIndex:indexPath.row] isKindOfClass:[PlayListSearch class]]) {
                        PlayListSearch *playlist = [self.videosArray objectAtIndex:indexPath.row];
                        NSLog(@"Playlist la: %@", playlist.playlistId);
                        [self.categoryDelegate categoryDidSelectPlayList:playlist];
                    }
            }
        }
        
    } else {
        if ([self.categoryDelegate respondsToSelector:@selector(categoryDidSelectChanel:)]) {
            Channel *chanel = [self.videosArray objectAtIndex:indexPath.row];
            [self.categoryDelegate categoryDidSelectChanel:chanel];
        } else {
            if ([self.categoryDelegate respondsToSelector:@selector(categoryDidSelectVideo:)]) {
                if ([[self.videosArray objectAtIndex:indexPath.row] isKindOfClass:[CategoryVideo class]]) {
                    CategoryVideo *video = [self.videosArray objectAtIndex:indexPath.row];
                    video.isChannelVideo = YES;
                    [self.categoryDelegate categoryDidSelectVideo:video];
                }
                if ([[self.videosArray objectAtIndex:indexPath.row] isKindOfClass:[PlaylistObject class]]) {
                    PlaylistObject *video = [self.videosArray objectAtIndex:indexPath.row];
        
                    [self.categoryDelegate baseCategoryDidSelectPlaylistItem:video];
                }

            }
        }
    }
    
}

#pragma mark Actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == self.listPlayArray.count + 1) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Playlist" message:@"Enter the playlist name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert showWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSString *name = [alertView textFieldAtIndex:0].text;
                
                [[SACoreDataManament sharedCoreDataManament] saveMyListWithName:name completion:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        if (objects.count > 0) {
                            // Alert name list is existed
                            [self showAlertWithTitle:@"Name Exists" message:[NSString stringWithFormat:@"The name \"%@\" already exists. Please choose a different name", name] ];
                            
                        } else {
                            // Show new list
                            [self fetchAllPlayList];
                            
                            // Notification update
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_MY_LIST_2 object:nil];
                        }
                    } else {
                        [self showAlertWithTitle:nil message:[error localizedDescription]];
                    }
                }];
            }
        }];
    } else if(buttonIndex > 0){
        NSString *titleList = [actionSheet buttonTitleAtIndex:buttonIndex];

        [[SACoreDataManament sharedCoreDataManament] addVideoToMyList:titleList video:_categoryVideo];
    }
}

#pragma mark Private methods
/*!
 * Show message
 */
- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

- (NSString*)formatNumberIntoDecimal:(NSInteger)number
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:number]];
    
    return formatted;
}

- (NSString*)parseISO8601Time:(NSString*)duration
{
    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    
    //Get Time part from ISO 8601 formatted duration http://en.wikipedia.org/wiki/ISO_8601#Durations
    duration = [duration substringFromIndex:[duration rangeOfString:@"T"].location];
    
    while ([duration length] > 1) { //only one letter remains after parsing
        duration = [duration substringFromIndex:1];
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:duration];
        
        NSString *durationPart = [[NSString alloc] init];
        [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] intoString:&durationPart];
        
        NSRange rangeOfDurationPart = [duration rangeOfString:durationPart];
        
        duration = [duration substringFromIndex:rangeOfDurationPart.location + rangeOfDurationPart.length];
        
        if ([[duration substringToIndex:1] isEqualToString:@"H"]) {
            hours = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"M"]) {
            minutes = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"S"]) {
            seconds = [durationPart intValue];
        }
    }
    
    if (hours == 0) {
        return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.startingOffset = MIN(MAX(scrollView.contentOffset.y, 0), scrollView.contentSize.height - scrollView.frame.size.height);
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if([self.categoryDelegate respondsToSelector:@selector(categoryDidScroll:)]){
        [self.categoryDelegate categoryDidScroll:scrollView];
    }
    
    // If user scrolled to the next loading point, load next page
    if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height * 3) {
        if ([self.categoryDelegate respondsToSelector:@selector(loadNextPage)]) {
            [self.categoryDelegate loadNextPage];
        }
    }
}
@end
