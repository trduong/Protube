//
//  HistoryViewController.m
//  ProTubeClone
//
//  Created by Hoang on 1/30/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "HistoryViewController.h"
#import "DetailViewController.h"

#import "HomeCollectionViewCell.h"
#import "NSDate+PrettyTimestamp.h"
#import "NSString+NumberChecking.h"
#import "UIImageView+WebCache.h"

#import "CategoryVideo.h"

#import "History.h"
#import "MyListPlay.h"
#import "MyList.h"

#define HOME_CELL_IDENTIFIER        @"HOME_CELL_IDENTIFIER"

@interface HistoryViewController ()<UIActionSheetDelegate>

@property (assign, nonatomic) NSInteger numberItems;
@property (strong, nonatomic) NSMutableArray   * videosArray;
@property (strong, nonatomic) NSMutableArray   * listPlayArray;
@property (assign, nonatomic) BOOL isModeEdit;

@property (strong, nonatomic) UIBarButtonItem *backBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *clearAllBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *doneBarButtonItem;

@property (strong, nonatomic) UIActivityIndicatorView   *indicatorView;

@end

@implementation HistoryViewController
{
    CategoryVideo *_selectedAddVideo;
    NSString *nextPageToken;
    
    BOOL isLoading;
    BOOL isLoadNextPage;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayList:) name:NOTIFICATION_UPDATE_MY_LIST object:nil];
    
    self.videosArray = [[NSMutableArray alloc] init];
    
    self.listPlayArray = [[NSMutableArray alloc] init];
    [self fetchAllPlayList];
    
    nextPageToken = @"";
    
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set image button
    self.navigationItem.leftBarButtonItem = self.backBarButtonItem;
    
    [self.view addSubview:self.collectionView];
    
    if (!self.isPlaylistItem) {
        self.navigationItem.rightBarButtonItem = self.editBarButtonItem;
        [self loadAllVideos];
    } else {
        self.navigationItem.title = self.playListItem.snippet.titleSnippet;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isPlaylistItem) {
        self.navigationItem.title = self.playListItem.snippet.titleSnippet;
    }
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
#pragma mark - Getters
- (UIActivityIndicatorView*)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds) - 50.0f)/2, 20.0f, 50.0f, 50.0f)];
        [_indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
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

- (UIBarButtonItem*)clearAllBarButtonItem
{
    if (!_clearAllBarButtonItem) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 26.0f)];
        [button setTitle:@"Clear All" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:247/255.0f green:0/255.0f blue:2/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [button addTarget:self action:@selector(clearAllAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _clearAllBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _clearAllBarButtonItem;
}


- (UIBarButtonItem*)editBarButtonItem
{
    if (!_editBarButtonItem) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 35.0f, 26.0f)];
        [button setTitle:@"Edit" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:247/255.0f green:0/255.0f blue:2/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [button addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _editBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _editBarButtonItem;
}

- (UIBarButtonItem*)doneBarButtonItem
{
    if (!_doneBarButtonItem) {
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 45.0f, 26.0f)];
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:247/255.0f green:0/255.0f blue:2/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [button addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _doneBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _doneBarButtonItem;
}

#pragma mark -
- (void)updatePlayList:(NSNotification*)notification
{
    [self fetchAllPlayList];
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

- (void)loadAllVideos
{
    [[SACoreDataManament sharedCoreDataManament] getAllVideoInHistoryWithCompletion:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (History *item in objects) {
                CategoryVideo *object = [[CategoryVideo alloc] init];
                object.videoId = item.videoId;
                object.date = item.created;
                
                Snippet *snippet = [[Snippet alloc] init];
                snippet.titleSnippet = item.title;
                snippet.descriptionSnippet = item.subTitle;
                snippet.channelTitle = item.channelTitle;
                
                VideoThumbnail *thumbnail = [[VideoThumbnail alloc] init];
                thumbnail.urlThumbnail = item.urlThumbnail;
                
                ContentDetails *content = [[ContentDetails alloc] init];
                content.duration = item.duration;
                content.publishAt = item.publicAt;
                
                Statistics *statics = [[Statistics alloc] init];
                statics.likeCount = [item.likeCount integerValue];
                statics.dislikeCount = [item.dislikeCount integerValue];
                
                snippet.highThumbnail = thumbnail;
                object.contentDetails = content;
                object.snippet = snippet;
                object.statistics = statics;
                
                [self.videosArray addObject:object];
                
            }
            
            self.numberItems = self.videosArray.count;
            
            [self.collectionView reloadData];
        }
    }];
}

/*!
 * Show message
 */
- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

#pragma mark - Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:self.collectionLayout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:HOME_CELL_IDENTIFIER];
        
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
        _collectionLayout.footerReferenceSize = CGSizeMake(self.view.bounds.size.width, 51.0f);
    }
    return _collectionLayout;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HOME_CELL_IDENTIFIER forIndexPath:indexPath];
    
    // Set index path for cell
    cell.indexPathCell = indexPath;
    
    CategoryVideo *video = [self.videosArray objectAtIndex:indexPath.row];
    
    if (self.isPlaylistItem) {
        return [self configCellForPlayList:cell video:video];
    } else {
        return [self configCellForHistory:cell video:video];
    }

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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryVideo *video = [self.videosArray objectAtIndex:indexPath.row];
    
    DetailViewController *vcPlay = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    vcPlay.video = video;
    
    [self.navigationController pushViewController:vcPlay animated:YES];

}

#pragma mark Action
- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editAction:(id)sender
{
    if (!self.isModeEdit) {
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem;
        self.navigationItem.leftBarButtonItem = self.clearAllBarButtonItem;
    } else {
        self.navigationItem.rightBarButtonItem = self.editBarButtonItem;
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem;
    }
 
    self.isModeEdit = !self.isModeEdit;
    [self.collectionView reloadData];
}

- (void)clearAllAction:(id)sender
{
    NSString *cancelTitle = @"Cancel";
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:@"Clear All"
                                  otherButtonTitles:nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

// Delete video
- (void)deleteVideoAtIndexPath:(NSIndexPath*)indexPath
{
    CategoryVideo *video = [self.videosArray objectAtIndex:indexPath.row];
    [[SACoreDataManament sharedCoreDataManament] deleteVideoInHistoryWithId:video.videoId completion:^(BOOL success, NSError *error) {
        if (success) {
            [self.collectionView performBatchUpdates:^{
                [self.videosArray removeObjectAtIndex:indexPath.row];
                self.numberItems--;
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                
            } completion:^(BOOL finished) {
                [self.collectionView reloadData];
            }];
        }
    }];
}

// Add video to my list
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
    actionSheet.tag = 0;
    
    for (MyListPlay *item in self.listPlayArray) {
        [actionSheet addButtonWithTitle:item.nameList];
    }
    [actionSheet addButtonWithTitle:@"New Playlist"];
    
    actionSheet.destructiveButtonIndex = self.listPlayArray.count + 1;
    
    [actionSheet showInView:self.view];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 0) { // Tag add video
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
            
            [[SACoreDataManament sharedCoreDataManament] addVideoToMyList:titleList video:_selectedAddVideo];
        }
    } else {
        if (buttonIndex == 0) {
            [[SACoreDataManament sharedCoreDataManament] deleteAllVideoWithCompletion:^(BOOL success, NSError *error) {
                [self.videosArray removeAllObjects];
                self.numberItems = 0;
                [self.collectionView reloadData];
            }];
        }
    }
}

#pragma mark Config Cell
- (HomeCollectionViewCell*)configCellForPlayList:(HomeCollectionViewCell*)cell video:(CategoryVideo*)video
{
    [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:video.snippet.highThumbnail.urlThumbnail] placeholderImage:[UIImage imageNamed:@"default_thumbnail"]];
    cell.titleLabel.text = video.snippet.titleSnippet;
    cell.subTitleLabel.text = video.snippet.channelTitle;
    
    if (!video.isLoadedVideo) {
        [self requestVideoWithVideo:video cell:cell];
    } else {
        cell.userView.text = [NSString stringWithFormat:@"%@ views", [self formatNumberIntoDecimal:video.statistics.viewCount]];
        cell.durationLabel.text = [self parseISO8601Time:video.contentDetails.duration];
        
        // Resize numberVideosLabel
        [cell.durationLabel sizeToFit];
        CGRect rect = cell.durationLabel.frame;
        rect.size.width += 6.0f;
        rect.origin.x = CGRectGetMaxX(cell.thumbnail.frame) - rect.size.width;
        cell.durationLabel.frame = rect;
    }
    
    // Add video
    [cell setDidAddVideoBlock:^(id sender, NSIndexPath *indexPathCell) {
        _selectedAddVideo = [self.videosArray objectAtIndex:indexPathCell.row];
        [self openPlayListVideos];
    }];
    
    return cell;
}

- (HomeCollectionViewCell*)configCellForHistory:(HomeCollectionViewCell*)cell video:(CategoryVideo*)video
{
    [cell.thumbnail sd_setImageWithURL:[NSURL URLWithString:video.snippet.highThumbnail.urlThumbnail] placeholderImage:[UIImage imageNamed:@"default_thumbnail"]];
    cell.titleLabel.text = video.snippet.titleSnippet;
    cell.subTitleLabel.text = video.snippet.descriptionSnippet;
    if (![NSString isNumber:video.contentDetails.duration]) {
        cell.durationLabel.text = [self parseISO8601Time:video.contentDetails.duration];
    } else {
        cell.durationLabel.text = [self formatTimeFromSeconds:[video.contentDetails.duration intValue]];
    }
    
    cell.userView.text = [NSDate prettyTimestampSinceDate:video.date];
    
    if (self.isModeEdit) {
        [cell.deleteButton setHidden:NO];
    } else {
        [cell.deleteButton setHidden:YES];
    }
    
    // Delete video
    [cell setDidDeleteVideoBlock:^(id sender, NSIndexPath *indexPathCell) {
        [self deleteVideoAtIndexPath:indexPathCell];
    }];
    
    // Add video
    [cell setDidAddVideoBlock:^(id sender, NSIndexPath *indexPathCell) {
        _selectedAddVideo = [self.videosArray objectAtIndex:indexPathCell.row];
        [self openPlayListVideos];
    }];
    
    // Resize numberVideosLabel
    [cell.durationLabel sizeToFit];
    CGRect rect = cell.durationLabel.frame;
    rect.size.width += 6.0f;
    rect.origin.x = CGRectGetMaxX(cell.thumbnail.frame) - rect.size.width;
    cell.durationLabel.frame = rect;
    
    return cell;
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

#pragma mark Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // If user scrolled to the next loading point, load next page
    if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height * 3) {
        if (self.isPlaylistItem) {
            if (!isLoading && nextPageToken != nil) {
                [self loadNextPage];
            }
        }
        
    }
}

#pragma mark API
- (void)loadNextPage
{
    isLoadNextPage = YES;
    [self loadPlaylistItemWithCategoryVideo:self.playListItem];
}

- (void)loadPlaylistItemWithCategoryVideo:(PlaylistItem*)category
{
    // Start effect loading
    if (!isLoadNextPage) {
        [self startLoadingEffect];
    }
    
    isLoading = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *strToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    [[APIYoutubeManagement sharedAPIYoutubeManagement] getPlaylistItemWithId:category.playlistId accessToken:strToken pageToken:nextPageToken completion:^(id result, NSError *error) {
        
        if (!error) {
            NSArray *items = result[@"items"];
            nextPageToken = result[@"nextPageToken"];
            
            for (id item in items) {
                CategoryVideo *video = [[CategoryVideo alloc] init];
                video.videoId = item[@"contentDetails"][@"videoId"];
                
                // Content detail
                ContentDetails *contentDetails = [[ContentDetails alloc] init];
                contentDetails.publishAt = item[@"snippet"][@"publishedAt"];
               
                // Snipppet
                Snippet *snippet = [[Snippet alloc] init];
                snippet.channelId = item[@"snippet"][@"channelId"];
                snippet.channelTitle = item[@"snippet"][@"channelTitle"];
                snippet.descriptionSnippet = item[@"snippet"][@"description"];
                snippet.titleSnippet = item[@"snippet"][@"title"];
                
                // Thumbnail
                VideoThumbnail *highThumbnail = [[VideoThumbnail alloc] init];
                highThumbnail.urlThumbnail =  item[@"snippet"][@"thumbnails"][@"high"][@"url"];
                
                snippet.highThumbnail = highThumbnail;
                
                video.snippet = snippet;
                video.contentDetails = contentDetails;
    
                [self.videosArray addObject:video];
            }
            
            self.numberItems = [self.videosArray count];
            [self.collectionView reloadData];
        }
        
        // Stop loading effect
        isLoadNextPage = NO;
        isLoading = NO;
        [self stopLoadingEffect];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    }];
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
                    categoryVideo.videoId = videoResult[@"id"];
                    
                    // Content details
                    categoryVideo.contentDetails.duration = videoResult[@"contentDetails"][@"duration"];
                    
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

- (NSString*)formatNumberIntoDecimal:(NSInteger)number
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:number]];
    
    return formatted;
}

@end
