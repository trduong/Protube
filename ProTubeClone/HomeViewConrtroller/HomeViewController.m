//
//  HomeViewController.m
//  ProTubeClone
//
//  Created by Hoang on 12/29/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "PlayVideoViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "RegionTableViewController.h"

#import "HomeCollectionViewCell.h"
#import "LeftMenuViewController.h"
#import "GooglePlus/GooglePlus.h"
#import "GoogleOpenSource/GoogleOpenSource.h"
#import "CategoryVideo.h"
#import "ActivityObject.h"
#import "PlaylistObject.h"
#import "PlaylistItem.h"
#import "UIImageView+WebCache.h"
#import "PlayYoutubeVideoViewController.h"
#import "HeaderSubscribe.h"
#import "DetailViewController.h"
#import "HistoryViewController.h"

#import "XMLReader.h"

@interface HomeViewController ()<RegionTableViewControllerDelegate>
{
    NSString *token;
    
    MenuItem *menuItem;
    
    BOOL _isFromPlaylist;
    BOOL _isFirtDisplay;
    BOOL _editMode;
    
    NSInteger totalVideos;
    
}

@property (strong, nonatomic) UIView            *headerContentView;

/* Horizontal menu buttons */
@property (strong, nonatomic) UIView            *horizonMenuButton;
@property (strong, nonatomic) NSMutableArray    *menuItemsArray;
@property (strong, nonatomic) UIView            *barView;
@property (assign, nonatomic) NSInteger indexOfMenu;

@property (strong, nonatomic) UIBarButtonItem           *leftBarItem;
@property (strong, nonatomic) UIBarButtonItem           *backBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem           *rightBarItem;

// Banner
@property (strong, nonatomic) HeaderSubscribe    *headerCollectionView;

// Play list buttons
@property (strong, nonatomic) NSMutableArray   *buttonsPlayList;
@property (strong, nonatomic) UIBarButtonItem   * editBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem   * addBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem   * doneBarButtonItem;

@end

@implementation HomeViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    menuItem = [[MenuItem alloc] init];
    menuItem.menuId = @"24"; // Entertainment
    
    
    //self.catgoryID = 24; // Entertainment
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.buttonsPlayList = [[NSMutableArray alloc] initWithCapacity:2];
    [self.buttonsPlayList addObject:self.editBarButtonItem];
    [self.buttonsPlayList addObject:self.addBarButtonItem];
    
    self.categoryDelegate = self;
    
    if (self.showFromSearch) {
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem;
    } else {
        self.navigationItem.leftBarButtonItem = self.leftBarItem;
    }
    
    NSString *strToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if (!([strToken length] > 0)) {
        self.navigationItem.title = @"Entertainment";
        self.navigationItem.rightBarButtonItem = self.rightBarItem;
        
        // Banner
        if (self.showMenuBar) {
            self.navigationItem.leftBarButtonItem = self.leftBarItem;
            _isFirtDisplay = YES;
        }
        
        if (isActivityPage) {
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.title = menuItem.titleMenu;
        }
        
        // Load videos
        if (!isChannelView) {
            [self loadVideosWithCategoryId:[menuItem.menuId integerValue] regionCode:[self appDelegate].regionSelected.regionCode];
        }
    }
    
   [self.view bringSubviewToFront:self.adsBannerView];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.showMenuBar) {
        return CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.headerContentView.frame));
    }
    
    // When user selected from left menu and subscription
    if (isSelectedFromMenu && menuItem.isKindSubscription) {
        return CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.headerContentView.frame));
    }
    
    return CGSizeZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isFirtDisplay = NO;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark Getters
- (UIView*)headerContentView
{
    if (!_headerContentView) {
        _headerContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 64.0f, CGRectGetWidth(self.view.bounds), 133.0f + 41.0f)];
        [_headerContentView setBackgroundColor:[UIColor whiteColor]];
        
        [_headerContentView addSubview:self.headerCollectionView];
        [_headerContentView addSubview:self.horizonMenuButton];
    }
    return _headerContentView;
}

- (HeaderSubscribe*)headerCollectionView
{
    if (!_headerCollectionView) {
        _headerCollectionView = [[HeaderSubscribe alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), 133.0f)];
        _headerCollectionView.parentViewController = self;
    }
    return _headerCollectionView;
}

- (NSMutableArray*)menuItemsArray
{
    if (!_menuItemsArray) {
        _menuItemsArray = [[NSMutableArray alloc] init];
        NSArray *titles = @[@"Activity", @"Videos", @"Playlists"];
        for (int i = 0; i < titles.count; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/3 * i, 0.0f, CGRectGetWidth(self.view.frame)/3, 41.0f)];
            [button setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:212/255.0f green:78/255.0f blue:78/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
            [button setTitleColor:[UIColor colorWithRed:212/255.0f green:78/255.0f blue:78/255.0f alpha:1.0f] forState:UIControlStateSelected];
            [button.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [_menuItemsArray addObject:button];
            [[_menuItemsArray objectAtIndex:0] setSelected:YES];
        }
    }
    return _menuItemsArray;
}

- (UIView*)horizonMenuButton
{
    if (!_horizonMenuButton) {
        _horizonMenuButton = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.headerCollectionView.frame), CGRectGetWidth(self.view.bounds), 41.0f)];
        [_horizonMenuButton setBackgroundColor:[UIColor whiteColor]];
        
        // Top line
        UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), 1.0f)];
        [top setBackgroundColor:[UIColor colorWithRed:178/255.0f green:178/255.0f blue:178/255.0f alpha:1.0f]];
        [_horizonMenuButton addSubview:top];
        
        // Bottom line
        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(_horizonMenuButton.frame) - 1.0f, CGRectGetWidth(self.view.bounds), 1.0f)];
        [bottom setBackgroundColor:[UIColor colorWithRed:213/255.0f green:213/255.0f blue:213/255.0f alpha:1.0f]];
        [_horizonMenuButton addSubview:bottom];
        
        for (int i = 0; i < 2; i++) {
            [_horizonMenuButton addSubview:[self dividerAt:i]];
        }
        
        for (int i = 0; i < 3; i++) {
            [_horizonMenuButton addSubview:[self.menuItemsArray objectAtIndex:i]];
        }
        
        for (int i = 0; i < self.menuItemsArray.count; i++) {
            [[self.menuItemsArray objectAtIndex:i] setSelected:NO];
        }
        [[self.menuItemsArray objectAtIndex:self.indexOfMenu] setSelected:YES];
        [self.horizonMenuButton addSubview:self.barView];
        
    }
    return _horizonMenuButton;
    
}

- (UIView *)dividerAt:(NSInteger)index
{
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(self.horizonMenuButton.bounds.size.width / 3 * (index + 1), (CGRectGetHeight(self.horizonMenuButton.frame) - 27.0f)/2, 1.0f, 27.0f)];
    divider.backgroundColor = [UIColor colorWithRed:207/255.0f green:207/255.0f blue:207/255.0f alpha:1.0f];
    return divider;
}

- (UIView*)barView
{
    if (!_barView) {
        _barView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.horizonMenuButton.frame) - 2.0f, CGRectGetWidth(self.horizonMenuButton.frame)/3, 2.0f)];
        [_barView setBackgroundColor:[UIColor colorWithRed:212/255.0f green:78/255.0f blue:78/255.0f alpha:1.0f]];
    }
    return  _barView;
}

- (UIBarButtonItem*)backBarButtonItem
{
    if (!_backBarButtonItem) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 26.0f, 26.0f)];
        [button setImage:IMAGE_BACK forState:UIControlStateNormal];
        [button setImage:IMAGE_BACK forState:UIControlStateHighlighted];
        [button setImage:IMAGE_BACK forState:UIControlStateSelected];
        [button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _backBarButtonItem;
}

- (UIBarButtonItem*)leftBarItem
{
    if (!_leftBarItem) {
        UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 19)];
        [button setImage:[UIImage imageNamed:@"mt_side_tab_button"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(slideMenuPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _leftBarItem;
}

- (UIBarButtonItem*)rightBarItem
{
    if (!_rightBarItem) {
        UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [button setImage:[UIImage imageNamed:@"US"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(regionPressed:) forControlEvents:UIControlEventTouchUpInside];
        _rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _rightBarItem;
}

- (UIBarButtonItem*)editBarButtonItem
{
    if (!_editBarButtonItem) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 45.0f, 26.0f)];
        [button setTitle:@"Edit" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:247/255.0f green:0/255.0f blue:2/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
        [button addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        _editBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _editBarButtonItem;
}

- (UIBarButtonItem*)addBarButtonItem
{
    if (!_addBarButtonItem) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 26.0f, 26.0f)];
        [button setImage:[UIImage imageNamed:@"add_playlist"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(addPlayListPressed:) forControlEvents:UIControlEventTouchUpInside];
        _addBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _addBarButtonItem;
}

- (UIBarButtonItem*)doneBarButtonItem
{
    if (!_doneBarButtonItem) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 26.0f)];
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:247/255.0f green:0/255.0f blue:2/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
        [button addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        _doneBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _doneBarButtonItem;
    
}
#pragma mark Query
-(void)requestDataWithPlayListItemsWithType:(int)type
{
    numberOfPlaylistItem = type;
    
    switch (type) {
        case 0: // Subcriptions
            [self requestSubcriptionsWithAccessToken:token pageToken:self.nextPageToken];
            break;
            
        case 1: // What to Watch
            [self requestVideosWatchToWatchWithAccessToken:token pageToken:self.nextPageToken];
            break;
            
        case 2: // Favorite
            [self requestVideosWithPlaylistItem:menuItem.menuId accessToken:token pageToken:self.nextPageToken];
            break;
            
        case 3: // Watch late
            [self requestVideosWithPlaylistItem:menuItem.menuId accessToken:token pageToken:self.nextPageToken];
            break;
            
        case 4: // Play list
            [self requestPlaylistWithAccessToken:token pageToken:self.nextPageToken isReload:NO];
            break;
            
        default:
            break;
    }
}


-(NSString*)calDuration:(NSString *)duration{
    @try {
        
        duration=duration.lowercaseString;
        if(duration.length>2){
            duration=[duration substringFromIndex:2];
            int hours,mins,seconds;
            if([duration rangeOfString:@"h"].location!=NSNotFound)
            {
                NSArray *arr=[duration componentsSeparatedByString:@"h"];
                hours=[arr[0]intValue];
                NSArray *arr1=[arr[1] componentsSeparatedByString:@"m"];
                mins=[arr1[0] intValue];
                seconds=[arr1[1] intValue];
            }
            else if([duration rangeOfString:@"m"].location!=NSNotFound)
            {
                hours=0;
                NSArray *arr1=[duration componentsSeparatedByString:@"m"];
                mins=[arr1[0] intValue];
                seconds=[arr1[1] intValue];
            }
            else
            {
                hours=0;
                mins=0;
                seconds=[duration intValue];
            }
            if(hours<10)
                duration=[NSString stringWithFormat:@"0%i",hours];
            else                    if(hours<10)
                duration=[NSString stringWithFormat:@"%i",hours];
            
            if(mins<10)
                duration=[NSString stringWithFormat:@"%@:0%i",duration,mins];
            else                    if(hours<10)
                duration=[NSString stringWithFormat:@"%@:%i",duration,mins];
            
            if(seconds<10)
                duration=[NSString stringWithFormat:@"%@:0%i",duration,seconds];
            else                    if(hours<10)
                duration=[NSString stringWithFormat:@"%@:%i",duration,seconds];
        }
        else{
            duration=@"00:00";
        }
        
    }
    @catch (NSException *exception) {
        
    }
    return duration;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Private methods
- (AppDelegate*)appDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark BaseVideo delegate
- (void)categoryDidScroll:(UIScrollView *)scrollView
{
    if (_isFirtDisplay) {
        return;
    }
    
    float scrollHeight = MIN( CGRectGetHeight(self.headerContentView.frame) - CGRectGetHeight(self.horizonMenuButton.frame), scrollView.contentOffset.y);
    
    self.headerContentView.frame = CGRectMake(0, (scrollHeight < 0.0f)?0:- scrollHeight, self.view.bounds.size.width, CGRectGetHeight(self.headerContentView.frame));

}

- (void)loadNextPage
{
    if (!self.isLoadingNextPage) {
        self.isLoadingNextPage = YES;
        if (!isActivityPage) {
            
            if (menuItem.isKindChannel) {
                
                if ([self validateNextPageToken:self.nextPageToken] || menuItem.orderItem == 1) {
                    [self requestDataWithPlayListItemsWithType:numberOfPlaylistItem];
                }
                
            } else if(menuItem.isKindSubscription){
                if (self.indexOfMenu == 0 ) { // Activity tab
                    if ([self validateNextPageToken:self.nextPageToken]) {
                        [self requestActivityPart:nil channelId:menuItem.menuId maxResult:50 pageToken:self.nextPageToken];
                    } else {
                        self.isLoadingNextPage = NO;
                    }
                } else if(self.indexOfMenu == 1){ // Videos tab
               
                } else { // Playlist tab
               
                }
            } else {
                // Load more video
                if ([self validateNextPageToken:self.nextPageToken]) {
                    [self loadVideosWithCategoryId:[menuItem.menuId integerValue] regionCode:[self appDelegate].regionSelected.regionCode];
                }
            }
        }
    }
}

// Validate next page token
- (BOOL)validateNextPageToken:(NSString*)nextPageToken
{
    if ([nextPageToken isEqualToString:@""]) {
        return NO;
    }
    
    if (!nextPageToken) {
        return NO;
    }
    
    return YES;
}

- (void)categoryDidSelectVideo:(CategoryVideo *)video
{
    if (!isPlayingVideo) {
        
        if (menuItem.orderItem == 4) {
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard_iPhone" bundle:nil];
            HistoryViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
            controller.isPlaylistItem = YES;
            controller.playListItem = (PlaylistItem*)video;
            [controller loadPlaylistItemWithCategoryVideo:(PlaylistItem*)video];
            
            [self.navigationController pushViewController:controller animated:YES];
            
        } else {
            isSearching = NO; // Load video same search
            isPlayingVideo = YES;
            
            DetailViewController *vcPlay = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
            vcPlay.video = video;
            
            [self.navigationController pushViewController:vcPlay animated:YES];
        }
        
    } else {
        if ([self.homeDelegate respondsToSelector:@selector(homeDidSelectVideo:)]) {
            [self.homeDelegate homeDidSelectVideo:video];
        }
    }
}

- (void)baseCategoryDidSelectPlaylistItem:(PlaylistObject*)object
{
    DetailViewController *vcPlay = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    vcPlay.playlistObject = object;
    
    isMoveToPlayVideoFromHome = YES;
    isPlayingVideo = YES;
    
    [self.navigationController pushViewController:vcPlay animated:YES];
}

#pragma mark API
- (void)loadVideosWithCategoryId:(NSInteger)categoryId regionCode:(NSString*)regionCode
{
    if (_isFromPlaylist) {
        return;
    }
    // Start effect loading
    if (!self.isLoadingNextPage) {
        [self startLoadingEffect];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[APIYoutubeManagement sharedAPIYoutubeManagement] getListVideoCategoryWithPart:@"snippet,statistics,contentDetails" videoCategoryId:categoryId regionCode:regionCode maxResult:50 chart:@"mostPopular" key:GOOGLE_KEY pageToken:((self.currentPage <=1)?@"":self.nextPageToken) completion:^(id result, NSError *error) {
        if (!error) {
            NSArray *items = [result objectForKey:@"items"];
            self.nextPageToken = [result objectForKey:@"nextPageToken"];
            
            if (!self.nextPageToken) {
                self.nextPageToken = @"";
            }
            
            for (id item in items) {
                
                CategoryVideo *video = [[CategoryVideo alloc] init];
                video.videoId = [item objectForKey:@"id"];
                
                NSDictionary *snippet = [item objectForKey:@"snippet"];
                if (snippet) {
                    Snippet *snippetObj = [[Snippet alloc] init];
                    snippetObj.categoryId = [snippet objectForKey:@"categoryId"];
                    snippetObj.channelId = [snippet objectForKey:@"channelId"];
                    snippetObj.channelTitle = [snippet objectForKey:@"channelTitle"];
                    snippetObj.descriptionSnippet = [snippet objectForKey:@"description"];
                    snippetObj.titleSnippet = [snippet objectForKey:@"title"];
                    
                    NSDictionary *thumbnails = [snippet objectForKey:@"thumbnails"];
                    NSDictionary *thumbnail = [thumbnails objectForKey:@"default"];
                    
                    // Default thumbnail
                    VideoThumbnail *videoThumbnail = [[VideoThumbnail alloc] init];
                    videoThumbnail.height = [[thumbnail objectForKey:@"height"] integerValue];
                    videoThumbnail.urlThumbnail = [thumbnail objectForKey:@"url"];
                    videoThumbnail.width = [[thumbnail objectForKey:@"width"] integerValue];
                    snippetObj.defaultThumbnail = videoThumbnail;
                    
                    // High thumbnail
                    thumbnail = [thumbnails objectForKey:@"high"];
                    videoThumbnail = [[VideoThumbnail alloc] init];
                    videoThumbnail.height = [[thumbnail objectForKey:@"height"] integerValue];
                    videoThumbnail.urlThumbnail = [thumbnail objectForKey:@"url"];
                    videoThumbnail.width = [[thumbnail objectForKey:@"width"] integerValue];
                    snippetObj.highThumbnail = videoThumbnail;
                    
                    // Medium thumbnail
                    thumbnail = [thumbnails objectForKey:@"medium"];
                    videoThumbnail = [[VideoThumbnail alloc] init];
                    videoThumbnail.height = [[thumbnail objectForKey:@"height"] integerValue];
                    videoThumbnail.urlThumbnail = [thumbnail objectForKey:@"url"];
                    videoThumbnail.width = [[thumbnail objectForKey:@"width"] integerValue];
                    snippetObj.mediumThumbnail = videoThumbnail;
                    
                    // Standard thumbnail
                    thumbnail = [thumbnails objectForKey:@"standard"];
                    videoThumbnail = [[VideoThumbnail alloc] init];
                    videoThumbnail.height = [[thumbnail objectForKey:@"height"] integerValue];
                    videoThumbnail.urlThumbnail = [thumbnail objectForKey:@"url"];
                    videoThumbnail.width = [[thumbnail objectForKey:@"width"] integerValue];
                    snippetObj.standardhumbnail = videoThumbnail;
                    
                    // store snippet
                    video.snippet = snippetObj;
                }
                
                // Statistics
                NSDictionary *statistics = [item objectForKey:@"statistics"];
                if (statistics) {
                    Statistics *statisticsObj = [[Statistics alloc] init];
                    statisticsObj.commentCount = [[statistics objectForKey:@"commentCount"] integerValue];
                    statisticsObj.dislikeCount = [[statistics objectForKey:@"dislikeCount"] integerValue];
                    statisticsObj.favoriteCount = [[statistics objectForKey:@"favoriteCount"] integerValue];
                    statisticsObj.likeCount = [[statistics objectForKey:@"likeCount"] integerValue];
                    statisticsObj.viewCount = [[statistics objectForKey:@"viewCount"] integerValue];
                    
                    // store statistics
                    video.statistics = statisticsObj;
                }
                
                // Content details
                NSDictionary *contentDetail = [item objectForKey:@"contentDetails"];
                if (contentDetail) {
                    ContentDetails *contentDetails = [[ContentDetails alloc] init];
                    contentDetails.caption = [contentDetail objectForKey:@"caption"];
                    contentDetails.definition = [contentDetail objectForKey:@"definition"];
                    contentDetails.dimension = [contentDetail objectForKey:@"dimension"];
                    contentDetails.duration = [contentDetail objectForKey:@"duration"];
                    contentDetails.licensedContent = [contentDetail objectForKey:@"licensedContent"];
                    contentDetails.publishAt = [[item objectForKey:@"snippet"] objectForKey:@"publishedAt"];
                    video.contentDetails = contentDetails;
                }
                
                // Store video item
                [self.videosArray addObject:video];
            }
            
            // Count videos
            self.numberItems = self.videosArray.count;
            
            // Reload
            [self.collectionView setDataSource:self];
            [self.collectionView setDelegate:self];
            [self.collectionView reloadData];
            
            self.isLoadingNextPage = NO;
            self.currentPage++;
            
        } else {
            // Handle error
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
        
        // Stop loading effect
        [self stopLoadingEffect];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

#pragma mark Public methods
- (void)reloadVideo
{
    //Reload token
    token = [[GPPSignIn sharedInstance] authentication].accessToken;
    
    // Remove all items
    [self.videosArray removeAllObjects];
    
    // Count videos
    self.numberItems = self.videosArray.count;
    
    // Reload datasource
    [self.collectionView reloadData];
    
    // reset current page
    self.currentPage = 1;
    
    // Reset token page
    self.nextPageToken = @"";
    
    if (menuItem.isKindChannel) {// channel
        [self requestDataWithPlayListItemsWithType:menuItem.orderItem];
        
    } else if(menuItem.isKindSubscription){ // subscription
        if (self.indexOfMenu == 0) {
            [self requestActivityPart:nil channelId:menuItem.menuId  maxResult:50 pageToken:self.nextPageToken];
        } else if(self.indexOfMenu == 1){
            // Load videos in channel
            [self requestActivityPart:nil channelId:menuItem.menuId  maxResult:50 pageToken:self.nextPageToken];
            
        } else {
            [self requestPlayListWithChannel:menuItem.menuId maxResult:50 pageToken:self.nextPageToken];
        }
    } else { // category videos
        [self loadVideosWithCategoryId:[menuItem.menuId integerValue] regionCode:[self appDelegate].regionSelected.regionCode];
    }

}


//-(void)doSomeMagic:(NSString *)limit {
//    
//    NSString *part=@"snippet";
//    NSString *access_token=@"&key=AIzaSyADMJu_68msQpWhuHv3b3xeodcOpYZCRyI";
//    NSString *url=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?&type=video&relatedToVideoId=%@&part=%@&maxResults=%@%@",self.videoID,part,@"50",access_token];
//    
//    dispatch_queue_t ParseQueue = dispatch_queue_create("ParseQueue", NULL);
//    dispatch_async(ParseQueue, ^{
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            
//            self.videosArray = [NSMutableArray array];
//            NSArray *array=[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
//            NSArray *arr=[array valueForKey:@"items"];
//            for (NSArray *arT in arr) {
//                
//                CategoryVideo *video = [[CategoryVideo alloc] init];
//                video.videoId = [[arT valueForKey:@"id"] valueForKey:@"videoId"];
//
//                NSDictionary *snippet = [arT valueForKey:@"snippet"];
//                if (snippet) {
//                    Snippet *snippetObj = [[Snippet alloc] init];
//                    snippetObj.categoryId = [snippet objectForKey:@"categoryId"];
//                    snippetObj.channelId = [snippet objectForKey:@"channelId"];
//                    snippetObj.channelTitle = [snippet objectForKey:@"channelTitle"];
//                    snippetObj.descriptionSnippet = [snippet objectForKey:@"description"];
//                    snippetObj.titleSnippet = [snippet objectForKey:@"title"];
//                    
//                    NSDictionary *thumbnails = [snippet objectForKey:@"thumbnails"];
//                    NSDictionary *thumbnail = [thumbnails objectForKey:@"default"];
//                    
//                    // Default thumbnail
//                    VideoThumbnail *videoThumbnail = [[VideoThumbnail alloc] init];
//                    videoThumbnail.height = [[thumbnail objectForKey:@"height"] integerValue];
//                    videoThumbnail.urlThumbnail = [thumbnail objectForKey:@"url"];
//                    videoThumbnail.width = [[thumbnail objectForKey:@"width"] integerValue];
//                    snippetObj.defaultThumbnail = videoThumbnail;
//                    
//                    // High thumbnail
//                    thumbnail = [thumbnails objectForKey:@"high"];
//                    videoThumbnail = [[VideoThumbnail alloc] init];
//                    videoThumbnail.height = [[thumbnail objectForKey:@"height"] integerValue];
//                    videoThumbnail.urlThumbnail = [thumbnail objectForKey:@"url"];
//                    videoThumbnail.width = [[thumbnail objectForKey:@"width"] integerValue];
//                    snippetObj.highThumbnail = videoThumbnail;
//                    
//                    // Medium thumbnail
//                    thumbnail = [thumbnails objectForKey:@"medium"];
//                    videoThumbnail = [[VideoThumbnail alloc] init];
//                    videoThumbnail.height = [[thumbnail objectForKey:@"height"] integerValue];
//                    videoThumbnail.urlThumbnail = [thumbnail objectForKey:@"url"];
//                    videoThumbnail.width = [[thumbnail objectForKey:@"width"] integerValue];
//                    snippetObj.mediumThumbnail = videoThumbnail;
//                    
//                    // Standard thumbnail
//                    thumbnail = [thumbnails objectForKey:@"standard"];
//                    videoThumbnail = [[VideoThumbnail alloc] init];
//                    videoThumbnail.height = [[thumbnail objectForKey:@"height"] integerValue];
//                    videoThumbnail.urlThumbnail = [thumbnail objectForKey:@"url"];
//                    videoThumbnail.width = [[thumbnail objectForKey:@"width"] integerValue];
//                    snippetObj.standardhumbnail = videoThumbnail;
//                    
//                    // store snippet
//                    video.snippet = snippetObj;
//                }
//                
//                // Statistics
//                NSDictionary *statistics = [arT valueForKey:@"statistics"];
//                if (statistics) {
//                    Statistics *statisticsObj = [[Statistics alloc] init];
//                    statisticsObj.commentCount = [[statistics objectForKey:@"commentCount"] integerValue];
//                    statisticsObj.dislikeCount = [[statistics objectForKey:@"dislikeCount"] integerValue];
//                    statisticsObj.favoriteCount = [[statistics objectForKey:@"favoriteCount"] integerValue];
//                    statisticsObj.likeCount = [[statistics objectForKey:@"likeCount"] integerValue];
//                    statisticsObj.viewCount = [[statistics objectForKey:@"viewCount"] integerValue];
//                    
//                    // store statistics
//                    video.statistics = statisticsObj;
//                }
//                
//                // Content details
//                NSDictionary *contentDetail = [arT valueForKey:@"contentDetails"];
//                if (contentDetail) {
//                    ContentDetails *contentDetails = [[ContentDetails alloc] init];
//                    contentDetails.caption = [contentDetail objectForKey:@"caption"];
//                    contentDetails.definition = [contentDetail objectForKey:@"definition"];
//                    contentDetails.dimension = [contentDetail objectForKey:@"dimension"];
//                    contentDetails.duration = [contentDetail objectForKey:@"duration"];
//                    contentDetails.licensedContent = [contentDetail objectForKey:@"licensedContent"];
//                    contentDetails.publishAt =[[arT valueForKey:@"snippet"] valueForKey:@"publishedAt"];
//                    
//                    video.contentDetails = contentDetails;
//                }
//
//               
//                
//                [ self.videosArray addObject:video];
//            }
//            // Count videos
//            self.numberItems = self.videosArray.count;
//            
//            // Reload
//            [self.collectionView setDataSource:self];
//            [self.collectionView setDelegate:self];
//            [self.collectionView reloadData];
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"LOG GET RALATED %@",error);
//        }];
//    });
//}

#pragma mark - Request Data
// Request api
- (void)requestActivityPart:(NSString*)part channelId:(NSString*)channelId maxResult:(NSInteger)maxResult pageToken:(NSString*)pageToken
{
    [[APIYoutubeManagement sharedAPIYoutubeManagement] getListActivitiesWithPart:part chanelId:channelId pageToken:pageToken maxResult:maxResult completion:^(id result, NSError *error) {
        
        if (!error) {
            NSArray *items = [result objectForKey:@"items"];
            self.nextPageToken = [result objectForKey:@"nextPageToken"];
            for (id item in items) {
                [self parseResponseActivityObject:item];
                
            }
            
            self.numberItems = self.videosArray.count;
            
            // Reload data
            [self.collectionView reloadData];
            
        } else {
       
        }
        
        self.isLoadingNextPage = NO;
    }];
}

// Request playlists
- (void)requestPlayListWithChannel:(NSString*)channel maxResult:(NSInteger)maxResult pageToken:(NSString*)pageToken
{
    [[APIYoutubeManagement sharedAPIYoutubeManagement] getPlaylistWithChannelId:channel pageToken:pageToken maxResult:maxResult completion:^(id result, NSError *error) {
        if (!error) {
            NSArray *items = [result objectForKey:@"items"];
            self.nextPageToken = [result objectForKey:@"nextPageToken"];
            
            for (id item in items) {
                PlaylistObject *playListObject = [[PlaylistObject alloc] init];
                playListObject.objectId = item[@"id"];
                
                // Content detail
                ContentDetails *contentDetail = [[ContentDetails alloc] init];
                contentDetail.itemCount = [item[@"contentDetails"][@"itemCount"] integerValue];
                playListObject.contentDetails = contentDetail;
                
                // Snippet
                Snippet *snippet = [[Snippet alloc] init];
                snippet.channelId = item[@"snippet"][@"channelId"];
                snippet.channelTitle = item[@"snippet"][@"channelTitle"];
                snippet.descriptionSnippet = item[@"snippet"][@"description"];
                snippet.titleSnippet = item[@"snippet"][@"title"];
                playListObject.snippet = snippet;
                
                // Thumbnail defaul
                VideoThumbnail *thumbnail = [[VideoThumbnail alloc] init];
                thumbnail.urlThumbnail = item[@"snippet"][@"thumbnails"][@"default"][@"url"];
                snippet.defaultThumbnail = thumbnail;
                
                // Thumbnail heigh
                thumbnail = [[VideoThumbnail alloc] init];
                thumbnail.urlThumbnail = item[@"snippet"][@"thumbnails"][@"high"][@"url"];
                snippet.highThumbnail = thumbnail;
                
                // Thumbnail medium
                thumbnail = [[VideoThumbnail alloc] init];
                thumbnail.urlThumbnail = item[@"snippet"][@"thumbnails"][@"medium"][@"url"];
                snippet.mediumThumbnail = thumbnail;
                
                [self.videosArray addObject:playListObject];
                
            }
            
            self.numberItems = self.videosArray.count;
            
            // Reload data
            [self.collectionView reloadData];
            
        }
    }];
}


// Request videos in playlist item
- (void)requestVideosWatchToWatchWithAccessToken:(NSString*)accessToken pageToken:(NSString*)pageToken
{
    if(!self.isLoadingNextPage){
        [self startLoadingEffect];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *url=[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/users/default/recommendations?v=2&max-results=50&key=%@&access_token=%@&start-index=%d", GOOGLE_KEY, token, self.currentPage];
    
    dispatch_queue_t ParseQueue = dispatch_queue_create("ParseQueue", NULL);
    
    dispatch_async(ParseQueue, ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (responseObject) {
                NSError *error = nil;
                NSDictionary *dict = [XMLReader dictionaryForXMLData:responseObject
                                                             options:XMLReaderOptionsProcessNamespaces
                                                               error:&error];
                if(!error){
                    
                    NSInteger startIndex = [dict[@"feed"][@"startIndex"][@"text"] integerValue];
                    totalVideos = [dict[@"feed"][@"totalResults"][@"text"] integerValue];
                    
                    self.currentPage = startIndex + 50;
                    
                    NSArray *entry = dict[@"feed"][@"entry"];
                    for (id item in entry) {
                        PlaylistItem *video = [[PlaylistItem alloc] init];
                        video.videoId = item[@"group"][@"videoid"][@"text"];
                        
                        Statistics *statistics = [[Statistics alloc] init];
                        statistics.favoriteCount = [item[@"statistics"][@"favoriteCount"] integerValue];
                        statistics.videoCount = [item[@"statistics"][@"viewCount"] integerValue];
                        
                        Snippet *snippet = [[Snippet alloc] init];
                        snippet.titleSnippet = item[@"title"][@"text"];
                        snippet.descriptionSnippet = item[@"group"][@"description"][@"text"];
                        snippet.channelTitle = item[@"group"][@"credit"][@"yt:display"];
                        
                        VideoThumbnail *thumbnail = [[VideoThumbnail alloc] init];
                        thumbnail.urlThumbnail = item[@"group"][@"thumbnail"][2][@"url"];
                        snippet.highThumbnail = thumbnail;
                        
                        ContentDetails *contentDetail = [[ContentDetails alloc] init];
                        contentDetail.publishAt = item[@"published"][@"text"];
                        contentDetail.duration = item[@"group"][@"duration"][@"seconds"];
                        
                        
                        video.snippet = snippet;
                        video.statistics = statistics;
                        video.contentDetails = contentDetail;
                        
                        [self.videosArray addObject:video];
                    }
                    
                    self.numberItems = self.videosArray.count;
                    
                    [self.collectionView reloadData];
                }
            }
            
            // Stop loading next page
            self.isLoadingNextPage = NO;
            
            [self stopLoadingEffect];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            // Stop loading next page
            self.isLoadingNextPage = NO;
            
            [self stopLoadingEffect];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    });
    
}



// Request videos in playlist item
- (void)requestPlaylistWithAccessToken:(NSString*)accessToken pageToken:(NSString*)pageToken isReload:(BOOL)isReload
{
    if(!self.isLoadingNextPage){
        [self startLoadingEffect];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[APIYoutubeManagement sharedAPIYoutubeManagement] getPlaylistWithToken:accessToken pageToken:pageToken completion:^(id result, NSError *error) {
        if (!error) {
            NSArray *items = result[@"items"];
            if (items) {
                
                if (isReload) {
                    [self.videosArray removeAllObjects];
                }
                
                for (id item in items) {
                    PlaylistItem *playlistItem = [[PlaylistItem alloc] init];
                    
                    // Snippet
                    Snippet *snippet = [[Snippet alloc] init];
                    snippet.channelId = item[@"snippet"][@"channelId"];
                    snippet.channelTitle = item[@"snippet"][@"channelTitle"];
                    snippet.descriptionSnippet = item[@"snippet"][@"description"];
                    playlistItem.playlistId = item[@"id"];
                    
                    // Thumbnail
                    VideoThumbnail *thumbnail = [[VideoThumbnail alloc] init];
                    thumbnail.urlThumbnail = item[@"snippet"][@"thumbnails"][@"high"][@"url"];
                    snippet.highThumbnail = thumbnail;
                    snippet.titleSnippet = item[@"snippet"][@"title"];
                    
                    ContentDetails *contentDetail = [[ContentDetails alloc] init];
                    contentDetail.itemCount = [item[@"contentDetails"][@"itemCount"] integerValue];
                    
                    playlistItem.snippet = snippet;
                    playlistItem.contentDetails = contentDetail;
                    
                    [self.videosArray addObject:playlistItem];
                }
                
                self.numberItems = self.videosArray.count;
                
                // Reload data source
                [self.collectionView reloadData];
            }
        }
        
        // Stop loading next page
        self.isLoadingNextPage = NO;
        
        [self stopLoadingEffect];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}



// Request videos in playlist item
- (void)requestVideosWithPlaylistItem:(NSString*)playlistItem accessToken:(NSString*)accessToken pageToken:(NSString*)pageToken
{
    if(!self.isLoadingNextPage){
        [self startLoadingEffect];
    }
    
    self.isWhatLater = YES;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[APIYoutubeManagement sharedAPIYoutubeManagement] getPlaylistItemWithId:playlistItem accessToken:accessToken pageToken:pageToken completion:^(id result, NSError *error) {
        if (!error) {
            NSArray *items = result[@"items"];
            if (items) {
                for (id item in items) {
                    PlaylistItem *playlistItem = [[PlaylistItem alloc] init];
                    
                    // Snippet
                    Snippet *snippet = [[Snippet alloc] init];
                    snippet.channelId = item[@"snippet"][@"channelId"];
                    snippet.channelTitle = item[@"snippet"][@"channelTitle"];
                    snippet.descriptionSnippet = item[@"snippet"][@"description"];
                    playlistItem.playlistId = item[@"snippet"][@"playlistId"];
                    playlistItem.videoId = item[@"snippet"][@"resourceId"][@"videoId"];

                    // Thumbnail
                    VideoThumbnail *thumbnail = [[VideoThumbnail alloc] init];
                    thumbnail.urlThumbnail = item[@"snippet"][@"thumbnails"][@"high"][@"url"];
                    snippet.highThumbnail = thumbnail;
                    snippet.titleSnippet = item[@"snippet"][@"title"];
                    
                    playlistItem.snippet = snippet;
                    
                    [self.videosArray addObject:playlistItem];
                }
                
                self.numberItems = self.videosArray.count;
                
                // Reload data source
                [self.collectionView reloadData];
            }
        }
        
        // Stop loading next page
        self.isLoadingNextPage = NO;
        
        [self stopLoadingEffect];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

// Request all videos subcriptions
- (void)requestSubcriptionsWithAccessToken:(NSString*)accessToken pageToken:(NSString*)pageToken
{
    if(!self.isLoadingNextPage){
        [self startLoadingEffect];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[APIYoutubeManagement sharedAPIYoutubeManagement] getSubciptionWithAccessToken:accessToken pageToken:pageToken completion:^(id result, NSError *error) {
        
        if (!error) {
            NSArray *items = result[@"items"];
            self.nextPageToken = result[@"nextPageToken"];
            
            for (id item in items) {
                [self parseResponseActivityObject:item];
            }
            
            // Count object
            self.numberItems = self.videosArray.count;
            
            // Reload
            [self.collectionView reloadData];
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        // Finished load page
        self.isLoadingNextPage = NO;
        
        // Stop loading
        [self stopLoadingEffect];
        
    }];
}

// Parse activity response from server
- (void)parseResponseActivityObject:(id)item
{
    ActivityObject *activity = [[ActivityObject alloc] init];
    activity.activityId = item[@"id"];
    
    // content detail
    id content = item[@"contentDetails"];
    ContentDetails *contentDetail = [[ContentDetails alloc] init];
    if (content) {
        id like = content[@"like"];
        if (like) {
            contentDetail.videoUploadId = like[@"resourceId"][@"videoId"];
        } else {
            contentDetail.videoUploadId = content[@"upload"][@"videoId"];
        }
        
        
        activity.videoId = contentDetail.videoUploadId;
        activity.contentDetails = contentDetail;
    }
    
    // snippet
    Snippet *snippet = [[Snippet alloc] init];
    id snippetObj = item[@"snippet"];
    snippet.channelId = snippetObj[@"channelId"];
    snippet.channelTitle = snippetObj[@"channelTitle"];
    snippet.descriptionSnippet = snippetObj[@"description"];
    snippet.titleSnippet = snippetObj[@"title"];
    contentDetail.publishAt = snippetObj[@"publishedAt"];
    
    // Thumbnail
    id thumbnailObj = snippetObj[@"thumbnails"];
    VideoThumbnail *thumbnail = [[VideoThumbnail alloc] init];
    
    // default
    thumbnail.urlThumbnail = thumbnailObj[@"default"][@"url"];
    snippet.defaultThumbnail = thumbnail;
    
    // high
    thumbnail = [[VideoThumbnail alloc] init];
    thumbnail.urlThumbnail = thumbnailObj[@"high"][@"url"];
    snippet.highThumbnail = thumbnail;
    
    // medium
    thumbnail = [[VideoThumbnail alloc] init];
    thumbnail.urlThumbnail = thumbnailObj[@"medium"][@"url"];
    snippet.mediumThumbnail = thumbnail;
    
    snippet.type = snippetObj[@"type"];
    
    activity.snippet = snippet;
    
    if (self.indexOfMenu == 0 && menuItem.isKindSubscription) {
        if (content && ([snippet.type isEqualToString:@"upload"] || [snippet.type isEqualToString:@"like"])) {
            [self.videosArray addObject:activity];
        }
    }
    
    if (self.indexOfMenu == 1 || menuItem.isKindChannel) {
        if (content && [snippet.type isEqualToString:@"upload"]) {
            [self.videosArray addObject:activity];
        }
    }
}
- (void)loadContentWithItem:(MenuItem*)item
{
    menuItem = item;
    self.navigationItem.title = item.titleMenu;
    self.isModeEdit = NO;
    
    isSubscription = NO;
    isPlaylistItem = NO;
    self.showMenuBar = NO;
    self.isWhatLater = NO;
    self.isLoadingNextPage = NO;
    
    // Hidden or display a region
    if (item.isKindChannel || item.isKindSubscription) {
        if (item.orderItem == 4) {
            [self.buttonsPlayList removeAllObjects];
            [self.buttonsPlayList addObject:self.editBarButtonItem];
            [self.buttonsPlayList addObject:self.addBarButtonItem];
            self.navigationItem.rightBarButtonItems = self.buttonsPlayList;
        } else {
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.rightBarButtonItems = nil;
        }
        
    } else {
        self.navigationItem.rightBarButtonItem = self.rightBarItem;
    }
    
    // Load videos
    if (item.isKindChannel) {
        isPlaylistItem = YES;
        
        // Remove header subcription
        [self.headerContentView removeFromSuperview];
        
        // Resize postion collection view
        [self resizePostionCollectionViewWithRect:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.collectionView.frame), CGRectGetHeight(self.view.frame))];
        
        [self reloadVideo];
        
    } else if(item.isKindSubscription){
        
        isSubscription = YES;
        self.showMenuBar = YES;
        
        // Set flag subcribe
        self.headerCollectionView.isSubscribe = isSelectedFromMenu;
        self.headerCollectionView.menuItem = menuItem;
        
        if (isSelectedFromMenu) {
            [self.headerCollectionView.subcriberButton setTitle:@"Subcribed" forState:UIControlStateNormal];
            [self.headerCollectionView.subcriberButton setImage:[UIImage imageNamed:@"unsubcribe"] forState:UIControlStateNormal];
        } else {
            [self.headerCollectionView.subcriberButton setTitle:@"Subcribe" forState:UIControlStateNormal];
            [self.headerCollectionView.subcriberButton setImage:[UIImage imageNamed:@"add_subcribe"] forState:UIControlStateNormal];
        }
        
        // Avatar
        [self.headerCollectionView.avatarImageView sd_setImageWithURL:[NSURL URLWithString:menuItem.imageName] placeholderImage:nil];
        
        // Load banner
       [[APIYoutubeManagement sharedAPIYoutubeManagement] getChannelInfoWithId:menuItem.menuId Completion:^(id result, NSError *error) {
           if (!error) {
               NSArray *items = result[@"items"];
               if (items) {
                   id resultObject = items[0];
                   id brandingSettings = resultObject[@"brandingSettings"];
                   
                   
                   [self.headerCollectionView.imageBackgroundView sd_setImageWithURL:[NSURL URLWithString:brandingSettings[@"image"][@"bannerMobileHdImageUrl"]] placeholderImage:nil];
                   
                   // nummber subcribers
                   self.headerCollectionView.subscriberLabel.text = [NSString stringWithFormat:@"%@ subcribers", [self formatNumberIntoDecimal:[resultObject[@"statistics"][@"subscriberCount"] integerValue]]];
                   
               }
               
           }
       }];
        
        // Display layout subscription
        [self.view addSubview:self.headerContentView];
        
        // Resize header
        CGRect rect = self.headerContentView.frame;
        rect.origin.y = 0.0f;
        self.headerContentView.frame = rect;
        
        // Add title
        self.headerCollectionView.userNameLabel.text = item.titleMenu;
        
        // Load activity
        [self reloadVideo];
    
        
    } else {
        // Remove header subcription
        [self.headerContentView removeFromSuperview];
        
        // Resize postion collection view
        [self resizePostionCollectionViewWithRect:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.collectionView.frame), CGRectGetHeight(self.view.frame))];
        
        // reload
        [self reloadVideo];
    }
}

- (void)loadVideos:(NSArray*)videos
{
    _isFromPlaylist = true;
    self.videosArray = [NSMutableArray arrayWithArray:videos];
self.numberItems = self.videosArray.count;

// Reload
[self.collectionView setDataSource:self];
[self.collectionView setDelegate:self];
[self.collectionView reloadData];

}

- (void)loadRelatedVideoWith:(NSString*)videoID
{
    [self reloadVideo];
}

- (void)refreshMenuBar
{
    for (int i = 0; i < self.menuItemsArray.count; i++) {
        [[self.menuItemsArray objectAtIndex:i] setSelected:NO];
    }
    [[self.menuItemsArray objectAtIndex:self.indexOfMenu] setSelected:YES];
    
    [self refreshIndicator];
}

- (void)refreshIndicator {
    self.barView.frame = CGRectMake(self.horizonMenuButton.bounds.size.width / 3 * self.indexOfMenu, CGRectGetMinY(self.barView.frame), CGRectGetWidth(self.barView.frame), 2.0f);
}

#pragma mark - Format string
- (NSString*)formatNumberIntoDecimal:(NSInteger)number
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:number]];
    
    return formatted;
}


#pragma mark - IBActions -
- (void)regionPressed:(id)sender
{
    UINavigationController *navigation = [self.storyboard instantiateViewControllerWithIdentifier:@"RegionNavigation"];
    RegionTableViewController *regionController = [navigation.viewControllers objectAtIndex:0];
    regionController.regionDelegate = self;
    
    [self presentViewController:navigation animated:YES completion:nil];
}

-(void)slideMenuPressed:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonPressed:(id)sender
{
    if (self.indexOfMenu != [self.menuItemsArray indexOfObject:sender]) {
        self.indexOfMenu = [self.menuItemsArray indexOfObject:sender];
        
        gIndexOfTabHome = self.indexOfMenu;
        
        // Resize header
        
        // Reload videos
        [self reloadVideo];
        
        [self refreshMenuBar];
    }
}

/* Back button pressed */
- (void)backActionPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/* Add playlist */
- (void)addPlayListPressed:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Playlist" message:@"Enter the playlist name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert showWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            NSString *title = [alert textFieldAtIndex:0].text;
            NSString *strToken = [[GPPSignIn sharedInstance] authentication].accessToken;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            [[APIYoutubeManagement sharedAPIYoutubeManagement] addPlaylistWithTitle:title accessToken:strToken completion:^(id result, NSError *error) {
                if (!error) {
                    self.nextPageToken = @"";
                    self.isLoadingNextPage = YES;
                    [self requestPlaylistWithAccessToken:strToken pageToken:self.nextPageToken isReload:YES];
                } else {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
            }];
        }
    }];
}

- (void)editAction:(id)sender
{
    NSInteger index = [self.buttonsPlayList indexOfObject:self.editBarButtonItem];
    [self.buttonsPlayList replaceObjectAtIndex:index withObject:self.doneBarButtonItem];

    self.navigationItem.rightBarButtonItems = self.buttonsPlayList;
    
    self.isModeEdit = YES;
    [self.collectionView reloadData];
}

- (void)doneAction:(id)sender
{
    int index = [self.buttonsPlayList indexOfObject:self.doneBarButtonItem];
    [self.buttonsPlayList replaceObjectAtIndex:index withObject:self.editBarButtonItem];
    
    self.navigationItem.rightBarButtonItems = self.buttonsPlayList;
    
    self.isModeEdit = NO;
    [self.collectionView reloadData];
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

#pragma mark RegionDelegate
- (void)regionCancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)regionFinshed
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    if ([self appDelegate].regionSelected) {
        UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [button setImage:[UIImage imageNamed:[self appDelegate].regionSelected.nationalFlag] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(regionPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = self.rightBarItem;
        
        // Reload videos
        [self reloadVideo];
    }
}

@end
