//
//  PTSearchViewController.m
//  ProTubeClone
//
//  Created by Hoang on 1/16/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "PTSearchViewController.h"
#import "FilterViewController.h"
#import "CategoryVideo.h"
#import "Channel.h"
#import "PlayListSearch.h"
#import "DetailViewController.h"
#import "SuggestionParentView.h"
#import "PTSearchViewController.h"
#import "PlaylistObject.h"

@interface PTSearchViewController ()<FilterDelegate, SuggestionDelegate, HomeDelegate>

@property (strong, nonatomic) NSMutableArray    *menuItemsArray;
@property (strong, nonatomic) NSMutableArray    *suggestArray;

@property (strong, nonatomic) UISearchBar   * searchBar;

@property (assign, nonatomic) NSInteger indexOfMenu;
@property (strong, nonatomic) UIView    *barView;

@property (strong, nonatomic) UIButton  *filterButton;
@property (strong, nonatomic) UIView    *overlayView;
@property (strong, nonatomic) UIView    *clearOverlayView;

@property (strong, nonatomic) FilterViewController  *filterViewController;
@property (strong, nonatomic) SuggestionParentView  *suggestionView;

@end

@implementation PTSearchViewController
{
    NSString *_pageToken;
    NSString *_searchText;
    
    UITextField *_searchTextField;
    
    NSString *_order;
    NSString *_duration;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.suggestArray = [NSMutableArray new];
    
    return [super initWithCoder:aDecoder];
}

#pragma mark View lifecyle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setTranslucent:NO];

    self.searchBar = [UISearchBar new];
    [self.searchBar sizeToFit];
    [self.searchBar setFrame:CGRectMake(0.0f, CGRectGetMinY(self.searchBar.frame), CGRectGetWidth(self.view.frame) - 10.0f*2, CGRectGetHeight(self.searchBar.frame))];
    self.searchBar.delegate = self;
    //searchBar.showsCancelButton = YES;
    self.searchBar.barTintColor = gColorNavigation;

    UIView *barWrapper = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.searchBar.frame), CGRectGetHeight(self.searchBar.frame))];
    [barWrapper addSubview:self.searchBar];
    self.navigationItem.titleView = barWrapper;
    
    self.categoryDelegate = self;
    
    _searchTextField = [self.searchBar valueForKey:@"_searchField"];
    _searchTextField.backgroundColor = [UIColor colorWithRed:227/255.0f green:228/255.0f blue:230/255.0f alpha:1.0f];
    _searchTextField.rightView = self.filterButton;
    
    self.indexOfMenu = 0;
    _pageToken = @"";
    
    self.videosArray = [[NSMutableArray alloc] init];
    
    CGRect rect = self.menuBarView.frame;
    rect.origin.y = 0;
    self.menuBarView.frame = rect;
    
    // Add menu
    [self setUpMenuBar];
    
    // Resize collection view
    [self resizePostionCollectionViewWithRect:CGRectMake(0.0f, CGRectGetMaxY(self.menuBarView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.menuBarView.frame))];
    
    [self resizePostionActivityIndicatorView:CGPointMake((CGRectGetWidth(self.view.bounds) - 50.0f)/2, 0.0f)];
    
    // Add suggestion view
    [self.view addSubview:self.overlayView];
    [self.view addSubview:self.suggestionView];
    [self.view addSubview:self.clearOverlayView];
    
    [self.overlayView setHidden:YES];
    [self.clearOverlayView setHidden:YES];
    
    [self.view bringSubviewToFront:self.adsBannerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isSearching = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    isSearching = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark Getters
- (NSMutableArray*)menuItemsArray
{
    if (!_menuItemsArray) {
        _menuItemsArray = [[NSMutableArray alloc] init];
        NSArray *titles = @[@"Videos", @"Channels", @"Playlists"];
        for (int i = 0; i < titles.count; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/3 * i, 0.0f, CGRectGetWidth(self.view.frame)/3, CGRectGetHeight(self.menuBarView.frame))];
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

- (UIView *)dividerAt:(NSInteger)index
{
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(self.menuBarView.bounds.size.width / 3 * (index + 1), (CGRectGetHeight(self.menuBarView.frame) - 27.0f)/2, 1.0f, 27.0f)];
    divider.backgroundColor = [UIColor colorWithRed:207/255.0f green:207/255.0f blue:207/255.0f alpha:1.0f];
    return divider;
}

- (UIButton*)filterButton
{
    if (!_filterButton) {
        _filterButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
        [_filterButton setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
        [_filterButton addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterButton;
}

- (UIView*)barView
{
    if (!_barView) {
        _barView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.menuBarView.frame) - 2.0f, CGRectGetWidth(self.menuBarView.frame)/3, 2.0f)];
        [_barView setBackgroundColor:[UIColor colorWithRed:212/255.0f green:78/255.0f blue:78/255.0f alpha:1.0f]];
    }
    return _barView;
}

- (SuggestionParentView*)suggestionView
{
    if (!_suggestionView) {
        _suggestionView = [[SuggestionParentView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.menuBarView.frame), CGRectGetWidth(self.view.frame), 0.0f)];
        _suggestionView.delegate = self;
    }
    return _suggestionView;
}

- (UIView*)overlayView
{
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.menuBarView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        [_overlayView setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.7f]];
    }
    return _overlayView;
}

- (UIView*)clearOverlayView
{
    if (!_clearOverlayView) {
        _clearOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.menuBarView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64.0f - 51.0f)];
        [_clearOverlayView setBackgroundColor:[UIColor clearColor]];
    }
    return _clearOverlayView;
}

#pragma mark Private methods
- (void)setUpMenuBar
{
    for (int i = 0; i < 2; i++) {
        [self.menuBarView addSubview:[self dividerAt:i]];
    }
    
    for (int i = 0; i < 3; i++) {
        [self.menuBarView addSubview:[self.menuItemsArray objectAtIndex:i]];
    }
    
    for (int i = 0; i < self.menuItemsArray.count; i++) {
        [[self.menuItemsArray objectAtIndex:i] setSelected:NO];
    }
    [[self.menuItemsArray objectAtIndex:self.indexOfMenu] setSelected:YES];
    
    [self.menuBarView addSubview:self.barView];
}

- (NSString*)typeVideo
{
    if (self.indexOfMenu == 0) {
        return @"video";
    } else if(self.indexOfMenu == 1){
        return @"channel";
    } else {
        return @"playlist";
    }
}

- (NSString*)formatDateRFC3339:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
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
    self.barView.frame = CGRectMake(self.menuBarView.bounds.size.width / 3 * self.indexOfMenu, CGRectGetMinY(self.barView.frame), CGRectGetWidth(self.barView.frame), 2.0f);
}

- (void)autocompleteSegesstions:(NSString*)searchWish
{
    [[APIYoutubeManagement sharedAPIYoutubeManagement] suggestNameWithText:searchWish completion:^(id result, NSError *error) {
        if (!error) {
            NSString *str = [[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding];
            NSString *json = nil;
            NSScanner *scanner = [NSScanner scannerWithString:str];
            [scanner scanUpToString:@"[[" intoString:NULL]; // Scan to where the JSON begins
            [scanner scanUpToString:@",{" intoString:&json];
            
            if (json) {
                NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:NULL];
                
                [self.suggestArray removeAllObjects];
                
                for (int i=0; i != [jsonObject count]; i++) {
                    for (int j=0; j != 1; j++) {
                        
                        if (self.suggestArray.count >= 5) {
                            break;
                        }
                        
                        [self.suggestArray addObject:[[jsonObject objectAtIndex:i] objectAtIndex:j]];
                    }
                }
                
                // show text suggest
                [self.suggestionView reloadDatasource:self.suggestArray];
                [self.suggestionView resizeViewWithHeight:self.suggestArray.count * 40];
            }
            
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

- (void)reloadSearching
{
    [self.videosArray removeAllObjects];
    self.numberItems = 0;
    _pageToken = @"";
    
    [self.collectionView reloadData];
    
    NSString *dateString = [self formatDateRFC3339:[NSDate date]];
    
    [self searchVideoWithType:[self typeVideo] maxResults:20 pageToken:_pageToken searchString:_searchText keyAccessToken:GOOGLE_KEY order:@"relevance" videoDuration:@"any" publishedAfter:dateString publishedBefore:dateString];
}

#pragma mark SearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    _searchTextField.rightViewMode = UITextFieldViewModeNever;
    [self.suggestionView setHidden:NO];
    [self.overlayView setHidden:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.suggestionView setHidden:YES];
    [self.overlayView setHidden:YES];
    
    if (_searchText) {
        _searchTextField.rightViewMode = UITextFieldViewModeAlways;
    } else {
        _searchTextField.rightViewMode = UITextFieldViewModeNever;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.suggestionView setHidden:YES];
    [self.overlayView setHidden:YES];
    [self.clearOverlayView setHidden:NO];
    
    _searchTextField.rightViewMode = UITextFieldViewModeAlways;
    
    [self.videosArray removeAllObjects];
    self.numberItems = 0;
    _pageToken = @"";
    
    _searchText = searchBar.text;
    
    [self.collectionView reloadData];
    
    if (self.indexOfMenu == 0) {
        // Display filter
        [self.filterButton setHidden:NO];
        
        NSString *dateString = [self formatDateRFC3339:[NSDate date]];
        [self searchVideoWithType:[self typeVideo] maxResults:20 pageToken:_pageToken searchString:_searchText keyAccessToken:GOOGLE_KEY order:@"relevance" videoDuration:@"any" publishedAfter:dateString publishedBefore:dateString];
    } else if(self.indexOfMenu == 1){
        // Hidden filter
        [self.filterButton setHidden:YES];
        [self searchChannelWithName:_searchText maxResults:20 pageToken:_pageToken];
    } else {
        // Hidden filter
        [self.filterButton setHidden:YES];
        [self searchPlaylistWithName:_searchText maxResults:20 pageToken:_pageToken];
    }
   
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _searchText = searchText;
    if ([_searchText isEqualToString:@""]) {
        _searchText = nil;
    }
    
    // suggest
    if (_searchText) {
        [self autocompleteSegesstions:_searchText];
    } else {
        [self.suggestionView resizeViewWithHeight:0];
    }

}

#pragma mark BaseCategory Delegate
- (void)loadNextPage
{
    if (!self.isLoadingNextPage && _pageToken) {
        self.isLoadingNextPage = YES;
        
        if (self.indexOfMenu == 0) {
            NSString *dateString = [self formatDateRFC3339:[NSDate date]];
            [self searchVideoWithType:[self typeVideo] maxResults:20 pageToken:_pageToken searchString:_searchText keyAccessToken:GOOGLE_KEY order:@"relevance" videoDuration:@"any" publishedAfter:@"" publishedBefore:dateString];
        } else if(self.indexOfMenu == 1){
             [self searchChannelWithName:_searchText maxResults:20 pageToken:_pageToken];
        } else {
            [self searchPlaylistWithName:_searchText maxResults:20 pageToken:_pageToken];
        }
    }
}

#pragma mark Filter Delegate
- (void)filterDidCancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)filterDidFinshed
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Suggestion delegate
- (void)suggestDidSelectItem:(NSString *)textSuggest
{
    _searchText = textSuggest;
    self.searchBar.text = textSuggest;
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    [self.suggestionView setHidden:YES];
    [self.overlayView setHidden:YES];
    
    // search
    [self reloadSearching];
}

#pragma mark-
- (void)categoryDidSelectVideo:(CategoryVideo *)video
{
    if (self.indexOfMenu == 0) {
        DetailViewController *vcPlay = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        vcPlay.video = video;
        
        [self.navigationController pushViewController:vcPlay animated:YES];
        
        isMoveToPlayVideoFromHome = NO;
        isPlayingVideo = YES;
    
    } else if(self.indexOfMenu == 1){
        
    }
    
}

#pragma mark-
- (void)categoryDidSelectPlayList:(PlayListSearch *)playlist
{
    DetailViewController *vcPlay = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    vcPlay.playlist = playlist;

    isMoveToPlayVideoFromHome = NO;
    isPlayingVideo = YES;
    
    [self.navigationController pushViewController:vcPlay animated:YES];
}

#pragma mark-
- (void)baseCategoryDidSelectPlaylistItem:(PlaylistObject *)object
{
    DetailViewController *vcPlay = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    vcPlay.playlistObject = object;
    
    isMoveToPlayVideoFromHome = NO;
    isPlayingVideo = YES;
    
    [self.navigationController pushViewController:vcPlay animated:YES];
}

- (void)categoryDidSelectChanel:(Channel *)chanel
{
    MenuItem *menuItem = [[MenuItem alloc] init];
    menuItem.menuId = chanel.channelId;
    menuItem.isKindSubscription = YES;
    
    VideoThumbnail *thumbnail = chanel.snippet.highThumbnail;
    menuItem.imageName = thumbnail.urlThumbnail;
    menuItem.titleMenu = chanel.snippet.titleSnippet;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard_iPhone" bundle:[NSBundle mainBundle]];
    HomeViewController *homeVC = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    homeVC.homeDelegate = self;
    homeVC.showFromSearch = YES;
    
    homeVC.navigationItem.title = menuItem.titleMenu;
    
    homeVC.showMenuBar = YES;
    [homeVC.videosArray removeAllObjects];
    
    isActivityPage = YES;
    
    [homeVC loadContentWithItem:menuItem];
    
    [self.navigationController pushViewController:homeVC animated:YES];
}

#pragma mark Action
- (void)buttonPressed:(UIButton *)sender {
    if (self.indexOfMenu != [self.menuItemsArray indexOfObject:sender]) {
        self.indexOfMenu = [self.menuItemsArray indexOfObject:sender];
        
        gIndexTabSearch = (int)self.indexOfMenu;
        
        if (self.indexOfMenu == 1) {
            isChannelView = YES;
        } else {
            isChannelView = NO;
        }
        
        // Reset data
        self.numberItems = 0;
        [self.videosArray removeAllObjects];
        [self.collectionView reloadData];
        
        // reset page token
        _pageToken = @"";
        
        if (_searchText) {
            
            [self.clearOverlayView setHidden:NO];
            
            if (self.indexOfMenu == 0) {
                // Display filter
                [self.filterButton setHidden:NO];
                
                NSString *dateString = [self formatDateRFC3339:[NSDate date]];
                NSString *typeVideo = [self typeVideo];
                [self searchVideoWithType:typeVideo maxResults:50 pageToken:_pageToken searchString:_searchText keyAccessToken:GOOGLE_KEY order:@"relevance" videoDuration:@"any" publishedAfter:@"" publishedBefore:dateString];
            } else if(self.indexOfMenu == 1){
                // Display filter
                [self.filterButton setHidden:YES];
                [self searchChannelWithName:_searchText maxResults:50 pageToken:_pageToken];
            } else {
                // Display filter
                [self.filterButton setHidden:YES];
                [self searchPlaylistWithName:_searchText maxResults:50 pageToken:_pageToken];
            }
           
        }
        
        [self refreshMenuBar];
    }
}

- (void)filterButtonPressed:(id)sender
{
    UINavigationController *navigation = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterNavigationController"];
    FilterViewController *filterController = [navigation.viewControllers objectAtIndex:0];
    filterController.filterDelegate = self;
    
    [self.navigationController presentViewController:navigation animated:YES completion:nil];
}

#pragma mark API
- (void)searchVideoWithType:(NSString*)type
                 maxResults:(NSInteger)maxResults
                  pageToken:(NSString*)pageToken
               searchString:(NSString*)searchString
             keyAccessToken:(NSString*)keyAccessToken
                      order:(NSString*)order
              videoDuration:(NSString*)videoDuration
             publishedAfter:(NSString*)publishedAfter
            publishedBefore:(NSString*)publishedBefore
{
    // Start loading
    if (!self.isLoadingNextPage) {
        [self startLoadingEffect];
    }
    
     searchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[APIYoutubeManagement sharedAPIYoutubeManagement] searchVideoWithString:searchString pageToken:pageToken maxResult:maxResults order:order videoDuration:videoDuration publishedAfter:publishedAfter publishedBefore:publishedBefore completion:^(id result, NSError *error) {
        if (!error) {
            _pageToken = [result objectForKey:@"nextPageToken"];
            NSArray *items = [result objectForKey:@"items"];
            
            for (id item in items) {
                CategoryVideo *categoryVideo = [[CategoryVideo alloc] init];
                
                // Dictionary id
                NSDictionary *objId = [item objectForKey:@"id"];
                categoryVideo.videoId = [objId objectForKey:@"videoId"];
                
                // Snippet
                Snippet *snippet = [[Snippet alloc] init];
                NSDictionary *snippetDict = item[@"snippet"];
                snippet.channelId = snippetDict[@"channelId"];
                snippet.channelTitle = snippetDict[@"channelTitle"];
                snippet.descriptionSnippet = snippetDict[@"description"];
                
                // Thumbnail
                NSDictionary *thumbDict = snippetDict[@"thumbnails"];
                
                // Default thumbnail
                VideoThumbnail *thumbnail = [[VideoThumbnail alloc] init];
                thumbnail.urlThumbnail = thumbDict[@"default"][@"url"];
                snippet.defaultThumbnail = thumbnail;
                
                // High thumbnail
                thumbnail = [[VideoThumbnail alloc] init];
                thumbnail.urlThumbnail = thumbDict[@"high"][@"url"];
                snippet.highThumbnail = thumbnail;
                
                // Medium thumbnail
                thumbnail = [[VideoThumbnail alloc] init];
                thumbnail.urlThumbnail = thumbDict[@"medium"][@"url"];
                snippet.mediumThumbnail = thumbnail;
                
                snippet.titleSnippet = snippetDict[@"title"];
                categoryVideo.snippet = snippet;
                
                [self.videosArray addObject:categoryVideo];
            }
            
            self.numberItems = [self.videosArray count];
            
            // Reload data
            [self.collectionView reloadData];
            
        } else {
            // Alert message
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
        
        // Stop loading
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self stopLoadingEffect];
        self.isLoadingNextPage = NO;
        [self.clearOverlayView setHidden:YES];
    }];
}

// Search channel
- (void)searchChannelWithName:(NSString*)channelName
                   maxResults:(NSInteger)maxResults
                    pageToken:(NSString*)pageToken
{
    // Start loading
    if (!self.isLoadingNextPage) {
        [self startLoadingEffect];
    }
    
    channelName = [channelName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[APIYoutubeManagement sharedAPIYoutubeManagement] searchChannelWithString:channelName maxResult:maxResults pageToken:pageToken completion:^(id result, NSError *error) {
        
        if (!error) {
            _pageToken = [result objectForKey:@"nextPageToken"];
            NSArray *items = [result objectForKey:@"items"];
            
            for (id item in items) {
                Channel *channel = [[Channel alloc] init];
                channel.channelId = item[@"id"][@"channelId"];
                
                // Snippet
                Snippet *snippet = [[Snippet alloc] init];
                NSDictionary *snippetDict = item[@"snippet"];
                
                snippet.channelId = snippetDict[@"channelId"];
                snippet.channelTitle = snippetDict[@"channelTitle"];
                snippet.descriptionSnippet = snippetDict[@"description"];
                
                // Thumbnail
                NSDictionary *thumbnails = snippetDict[@"thumbnails"];
                // Default
                VideoThumbnail *thumbnail = [[VideoThumbnail alloc] init];
                thumbnail.urlThumbnail = thumbnails[@"default"][@"url"];
                snippet.defaultThumbnail = thumbnail;
                
                // High
                thumbnail = [[VideoThumbnail alloc] init];
                thumbnail.urlThumbnail = thumbnails[@"high"][@"url"];
                snippet.highThumbnail = thumbnail;
                
                // Medium
                thumbnail = [[VideoThumbnail alloc] init];
                thumbnail.urlThumbnail = thumbnails[@"medium"][@"url"];
                snippet.mediumThumbnail = thumbnail;
                
                snippet.titleSnippet = snippetDict[@"title"];
                
                
                channel.snippet = snippet;
                
                [self.videosArray addObject:channel];
            }
            
            self.numberItems = [self.videosArray count];
            
            // Reload data
            [self.collectionView reloadData];

        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
        
        // Stop loading
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self stopLoadingEffect];
        self.isLoadingNextPage = NO;
        [self.clearOverlayView setHidden:YES];
    }];
}

// Search playlist
- (void)searchPlaylistWithName:(NSString*)listName
                    maxResults:(NSInteger)maxResults
                     pageToken:(NSString*)pageToken
{
    if (!self.isLoadingNextPage) {
        [self startLoadingEffect];
    }
    
    listName = [listName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[APIYoutubeManagement sharedAPIYoutubeManagement] searchPlaylistsWithString:listName maxResult:20 pageToken:_pageToken completion:^(id result, NSError *error) {
        if (!error) {
            _pageToken = [result objectForKey:@"nextPageToken"];
            NSArray *items = [result objectForKey:@"items"];
            for (id item in items) {
                PlayListSearch *playListSearch = [[PlayListSearch alloc] init];
                playListSearch.playlistId = item[@"id"][@"playlistId"];
                
                // Snipppet
                Snippet *snippet = [[Snippet alloc] init];
                snippet.channelId = item[@"snippet"][@"channelId"];
                snippet.channelTitle = item[@"snippet"][@"channelTitle"];
                snippet.descriptionSnippet = item[@"snippet"][@"description"];
                
                // Thumbnail
                NSDictionary *thumbDict = item[@"snippet"][@"thumbnails"];
                
                // Default thumbnail
                VideoThumbnail *thumbnail = [[VideoThumbnail alloc] init];
                thumbnail.urlThumbnail = thumbDict[@"default"][@"url"];
                snippet.defaultThumbnail = thumbnail;
                
                // High thumbnail
                thumbnail = [[VideoThumbnail alloc] init];
                thumbnail.urlThumbnail = thumbDict[@"high"][@"url"];
                snippet.highThumbnail = thumbnail;
                
                // Medium thumbnail
                thumbnail = [[VideoThumbnail alloc] init];
                thumbnail.urlThumbnail = thumbDict[@"medium"][@"url"];
                snippet.mediumThumbnail = thumbnail;
                
                snippet.titleSnippet = item[@"snippet"][@"title"];
                
                playListSearch.snippet = snippet;
                
                [self.videosArray addObject:playListSearch];
                
            }
            
            self.numberItems = [self.videosArray count];
            
            // Reload data
            [self.collectionView reloadData];
            
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
        
        // Stop loading
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self stopLoadingEffect];
        self.isLoadingNextPage = NO;
        [self.clearOverlayView setHidden:YES];
    }];
}
@end
