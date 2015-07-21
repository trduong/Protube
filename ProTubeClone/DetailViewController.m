//
//  DetailViewController.m
//  ProTubeClone
//
//  Created by Apple on 18/08/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import "DetailViewController.h"
#import "XCDYouTubeVideoPlayerViewController.h"
#import "XCDYouTubeVideo.h"

#import <AFHTTPRequestOperationManager.h>
#import "MBProgressHUD.h"
#import "blockAV.h"
#import "CommentTableViewCell.h"
#import "AddCommentViewController.h"
#import "AppDelegate.h"

#import "CategoryVideo.h"
#import "HomeViewController.h"
#import "PlayListSearch.h"

#import "XMLReader.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 300.0f
#define CELL_CONTENT_MARGIN 10.0f

@interface DetailViewController ()
{
    NSMutableArray *_categories;
    HomeViewController *_videoListView;
    NSMutableArray *videoArrays;
    XCDYouTubeVideoQuality videoQuanlity;
}

@property (strong, nonatomic) NSMutableArray    *menuItemsArray;
@property (strong, nonatomic) NSMutableArray    *divItemsArray;

@property (assign, nonatomic) NSInteger indexOfMenu;
@property (strong, nonatomic) UIView    *bottomLine;

@property (strong, nonatomic) NSMutableArray  * leftBarButtonItems;
@property (strong, nonatomic) UIActivityIndicatorView   *videoIndicatorView;

@end

@implementation DetailViewController
{
    BOOL didSetupMenu;
    BOOL isCommentEmpty;
}

@synthesize aryTvHeight;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    videoQuanlity = [self videoquanlity];
    
    return [super initWithCoder:aDecoder];
}

- (XCDYouTubeVideoQuality)videoquanlity
{
    XCDYouTubeVideoQuality quanlity = XCDYouTubeVideoQualitySmall240;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *quanlityString = [userDefault objectForKey:@"quanlity"];
    if([quanlityString isEqualToString:@"360p"]){
        quanlity = XCDYouTubeVideoQualityMedium360;
    } else if([quanlityString isEqualToString:@"720p"]){
        quanlity = XCDYouTubeVideoQualityHD720;
    } else {
        quanlity = XCDYouTubeVideoQualityHD1080;
    }
    return quanlity;
}

- (NSString*)titleQuanlityVideo
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *quanlity = [userDefault objectForKey:@"quanlity"];
    if (!quanlity) {
        quanlity = @"240p";
    }
    return quanlity;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackStateChanged)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)playbackStateChanged {
    NSInteger result = self.videoPlayerViewController.moviePlayer.playbackState;
    if (result != MPMoviePlaybackStatePaused) {
        [self.tabarMenu setAlpha:0.0];
        [self.videoIndicatorView stopAnimating];
    } else {
        [self.tabarMenu setAlpha:1.0];
        [[self.view superview] bringSubviewToFront:self.tabarMenu];
    }
}

-(void)viewDidLayoutSubviews
{
    [self.tabarMenu setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    [self.tabarMenu setHidden:NO];
    [self.playMenu setBackgroundColor:[UIColor clearColor]];
    [self.playMenu setHidden:YES];
    
    // Video view
    [self.videoView setFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), IS_IPAD?300.0f:197.0f)];
    [self.videoPlayerViewController presentInView:self.videoView];
    
    // Menu
    [self.tabView setFrame:CGRectMake(0.0f, CGRectGetMinY(self.videoView.frame) + CGRectGetHeight(self.videoView.frame), CGRectGetWidth(self.view.frame), 42.0f)];
    
    // Info tab
    [self.viewInfo setFrame:CGRectMake(0, CGRectGetMaxY(self.tabView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.tabView.frame) - 55.0f)];
    [self.viewInfo setContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds),  CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.tabView.frame))];
    [self.viewInfo setShowsVerticalScrollIndicator:NO];
    
    // Video suggest
    [_videoListView.view setFrame:CGRectMake(0, CGRectGetMaxY(self.tabView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.tabView.frame))];
 
    // Comments tab
    [self.tvComments setFrame:CGRectMake(0, CGRectGetMaxY(self.tabView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.tabView.frame) - 51.0f)];

    [self.addMoreComment.layer setFrame:CGRectMake(10, 7, CGRectGetWidth(self.view.bounds) - 20.0f, 35)];
    [self.addMoreComment setBackgroundColor:[UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1.0]];
    self.addMoreComment.layer.shadowOffset = CGSizeMake(0, 2);
    self.addMoreComment.layer.shadowOpacity = 0.8;
    self.addMoreComment.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    
    [self.view bringSubviewToFront:self.videoView];
    [self.view bringSubviewToFront:self.tabarMenu];
    
    // Add menu
    if (!didSetupMenu) {
        [self setUpMenuBar];
        [self addBarButtonItemsNavigation];
        didSetupMenu = YES;
    }
    
}

- (void) hideControl
{
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self addBarButtonItemsNavigation];
    
    aryTvHeight = [NSMutableArray new];
    [self.videoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    _videoListView = [[HomeViewController alloc] init];
    _videoListView.homeDelegate = self;
    [self.view addSubview:_videoListView.view];
    [_videoListView.view setHidden:YES];
    
    
    if (self.video) {
        [self loadNewVideo];
    }
    else if (self.playlist)
    {
        [self loadVideoInPlaylist];
    }
    else if (self.playlistObject)
    {
        [self loadVideoInPlaylist];
    }
}

#pragma mark Getters
- (UIActivityIndicatorView*)videoIndicatorView
{
    if (!_videoIndicatorView) {
        _videoIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_videoIndicatorView setFrame:CGRectMake((CGRectGetWidth(self.videoView.frame) - CGRectGetWidth(_videoIndicatorView.frame))/2, (CGRectGetHeight(self.videoView.frame) - CGRectGetHeight(_videoIndicatorView.frame))/2, CGRectGetWidth(_videoIndicatorView.frame), CGRectGetHeight(_videoIndicatorView.frame))];
        [_videoIndicatorView setHidesWhenStopped:YES];
    }
    return _videoIndicatorView;
}

- (void)addBarButtonItemsNavigation
{
    self.leftBarButtonItems = [[NSMutableArray alloc] init];
    
    // init bar button items
    UIToolbar *toolbar = [[UIToolbar alloc]
                          initWithFrame:CGRectMake(0, 0, 200, 44)];
    [toolbar setBackgroundImage:[UIImage new]
             forToolbarPosition:UIToolbarPositionAny
                     barMetrics:UIBarMetricsDefault];
    [toolbar setBackgroundColor:[UIColor clearColor]];
    
    // Space button
    UIBarButtonItem *fixedSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace1.width = 30;
    
    UIBarButtonItem *fixedSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace2.width = CGRectGetWidth(self.view.frame) - 26.0f*3 - 20.0f - 30.0f*2 - 20.0f - 26.0f - 46.0f;
    
    // 1. Back bar button item
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 26.0f, 26.0f)];
    [button setImage:[UIImage imageNamed:@"circle-left"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"circle-left"] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"circle-left"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(btnBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.leftBarButtonItems addObject:barItem];
    [self.leftBarButtonItems addObject:fixedSpace1];
    
    // 2. Button play new tab
    button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 26.0f, 26.0f)];
    [button setImage:[UIImage imageNamed:@"circle-down"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"circle-down"] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"circle-down"] forState:UIControlStateSelected];
    barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.leftBarButtonItems addObject:barItem];
    [self.leftBarButtonItems addObject:fixedSpace1];
    
    // 3. Button add to my list
    button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 26.0f, 26.0f)];
    [button setImage:[UIImage imageNamed:@"addTo"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"addTo"] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"addTo"] forState:UIControlStateSelected];
    barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.leftBarButtonItems addObject:barItem];
    [self.leftBarButtonItems addObject:fixedSpace2];
    
    // 4. Button quanlity
    button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 26.0f)];
    [button setTitle:[self titleQuanlityVideo] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:173/255.0f green:66/255.0f blue:69/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [button addTarget:self action:@selector(selectQuanlityVideo:) forControlEvents:UIControlEventTouchUpInside];
    barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.leftBarButtonItems addObject:barItem];
    
    fixedSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace1.width = 10.0f;
    
    [self.leftBarButtonItems addObject:fixedSpace1];
    
    // 5. Button share
    button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 26.0f, 26.0f)];
    [button setImage:[UIImage imageNamed:@"share_tab"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"share_tab"] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"share_tab"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(shareVideo:) forControlEvents:UIControlEventTouchUpInside];
    barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.leftBarButtonItems addObject:barItem];
    
    self.navigationItem.leftBarButtonItems = self.leftBarButtonItems;
}

- (NSMutableArray*)menuItemsArray
{
    if (!_menuItemsArray) {
        _menuItemsArray = [[NSMutableArray alloc] init];
        NSArray *titles;
        titles = @[@"Info", @"Comments", @"Suggestions"];
        if (self.playlist) {
            titles = @[@"Info", @"Comments", @"Playlists"];
        }
        if (self.playlistObject) {
            titles = @[@"Info", @"Comments", @"Playlists"];
        }
        for (int i = 0; i < titles.count; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/3 * i, 0.0f, CGRectGetWidth(self.view.frame)/3, CGRectGetHeight(self.tabView.frame))];
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
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(self.tabView.bounds.size.width / 3 * (index + 1), (CGRectGetHeight(self.tabView.frame) - 27.0f)/2, 1.0f, 27.0f)];
    divider.backgroundColor = [UIColor colorWithRed:207/255.0f green:207/255.0f blue:207/255.0f alpha:1.0f];
    return divider;
}

- (void)setUpMenuBar
{
    self.divItemsArray = [NSMutableArray new];
    
    for (int i = 0; i < 2; i++) {
        [self.tabView addSubview:[self dividerAt:i]];
        [self.divItemsArray addObject:[self dividerAt:i]];
    }
    
    for (int i = 0; i < 3; i++) {
        [self.tabView addSubview:[self.menuItemsArray objectAtIndex:i]];
    }
    
    for (int i = 0; i < self.menuItemsArray.count; i++) {
        [[self.menuItemsArray objectAtIndex:i] setSelected:NO];
    }
    [[self.menuItemsArray objectAtIndex:self.indexOfMenu] setSelected:YES];
    
    [self.tabView addSubview:self.bottomLine];
    [self.tabView setBackgroundColor:[UIColor whiteColor]];
    
    CGRect rect = self.tabView.frame;
    rect.size.height = 42.0f;
    self.tabView.frame = rect;
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
    self.bottomLine.frame = CGRectMake(self.tabView.bounds.size.width / 3 * self.indexOfMenu, CGRectGetMinY(self.bottomLine.frame), CGRectGetWidth(self.bottomLine.frame), 2.0f);
}

- (UIView*)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.tabView.frame) - 2.0f, CGRectGetWidth(self.tabView.frame)/3, 2.0f)];
        [_bottomLine setBackgroundColor:[UIColor colorWithRed:212/255.0f green:78/255.0f blue:78/255.0f alpha:1.0f]];
    }
    return _bottomLine;
}

- (void)loadNewVideo
{
    [self.videoView addSubview:self.videoIndicatorView];
    [self.videoIndicatorView startAnimating];
    
    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:_video.videoId];
    [self.videoPlayerViewController presentInView:self.videoView];
    
    [self.videoView bringSubviewToFront:self.videoIndicatorView];
    
    [self.videoPlayerViewController.moviePlayer prepareToPlay];
    NSArray *preferredVideoQualities=[[NSArray alloc]initWithObjects:[NSNumber numberWithInt:videoQuanlity], nil];
    [self.videoPlayerViewController setPreferredVideoQualities:preferredVideoQualities];
    [self.videoPlayerViewController.moviePlayer play];
    
    [self loadComments];
    if (!self.playlist && videoArrays.count == 0 ) {
        [_videoListView loadRelatedVideoWith:_video.videoId];
    }
    else {
        [_videoListView loadVideos:videoArrays];
    }
    
    [self loadPlaylistItem];
    
    // Save video to history
    [[SACoreDataManament sharedCoreDataManament] addVideoToHistory:self.video];
    
}

- (void)loadPlaylistItem
{
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    appDelegate.isSend = NO;
    _data=[NSMutableArray new];
    _dataComments=[NSMutableArray new];
    
    // Do any additional setup after loading the view from its nib.
    
    _lblVideoTitle.text=_video.snippet.titleSnippet;
    
    @try
    {
        NSString *publish = [_video.contentDetails.publishAt copy];
        publish = [publish substringToIndex:10];
        
        // Convert string to date object
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormat dateFromString:publish];
        
        // Convert date object to desired output format
        [dateFormat setDateFormat:@"MMM dd, YYYY"];
        publish = [dateFormat stringFromDate:date];
        
        _lblLikeDislike.text=[NSString stringWithFormat:@"%ld Likes, %ld Dislikes",(long)_video.statistics.likeCount,(long)_video.statistics.dislikeCount];
        _lblFav.text = [NSString stringWithFormat:@"%ld views",(long)_video.statistics.viewCount];
        _tvDescription.text=nil;
        _tvDescription.dataDetectorTypes=UIDataDetectorTypeAll;
        _tvDescription.text= _video.snippet.descriptionSnippet;
        _lblChannelTitle.text=_video.snippet.channelTitle;
        _lblPublishedAt.text = publish;
        _ivChannelLogo.layer.cornerRadius=5;
        _ivChannelLogo.clipsToBounds=YES;
        
        NSString *picUrl=_video.snippet.highThumbnail.urlThumbnail;
        if([picUrl.lowercaseString hasSuffix:@".png"] || [picUrl.lowercaseString hasSuffix:@".jpg"] || [picUrl.lowercaseString hasSuffix:@".jpeg"] || [picUrl.lowercaseString hasSuffix:@".gif"])
        {
            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q, ^{
                NSData *dataPic = [NSData dataWithContentsOfURL:[[NSURL alloc] initWithString:picUrl]];
                UIImage *img = [[UIImage alloc] initWithData:dataPic];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _ivChannelLogo.image = img;
                });
            });
        }
        
        float total=_video.statistics.likeCount+_video.statistics.dislikeCount;
        float progress=_video.statistics.likeCount/total;
        _pvLikeDislikes.progress=progress;
    }
    @catch (NSException *exception) {
        _pvLikeDislikes.hidden=YES;
        _lblChannelTitle.text=_video.snippet.channelTitle;
    }
    //_lblTitle.text=_catTitle;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSString *refresh_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"refresh_token"]];
    if(refresh_token.length>7) {
        NSString *access_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"access_token"]];
        
        NSString *url=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/subscriptions?part=id,snippet&maxResults=50&forChannelId=%@&mine=true&access_token=%@",self.video.snippet.channelId,access_token];
        
        dispatch_queue_t ParseQueue = dispatch_queue_create("ParseQueue", NULL);
        dispatch_async(ParseQueue, ^{
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSArray *array=[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                NSArray *arr=[array valueForKey:@"items"] ;
                if(arr.count>0){
                    _subsId=[arr valueForKey:@"id"][0];
                    [_btnSubs setTitle:@"UnSubscribe" forState:UIControlStateNormal];
                    [_btnSubs setImage:[UIImage imageNamed:@"mt_subscribed_icon"] forState:UIControlStateNormal];
                    
                } else {
                    [_btnSubs setTitle:@"Subscribe" forState:UIControlStateNormal];
                    [_btnSubs setImage:[UIImage imageNamed:@"mt_subscribe_icon"] forState:UIControlStateNormal];
                }
                _AISubs.hidden=YES;
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@",error);
                _AISubs.hidden=YES;
            }];
        });
    } else{
        _AISubs.hidden=YES;
        _btnSubs.hidden=YES;
    }
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (_dataComments.count != 0 && appDelegate.isSend == YES) {
        //[_dataComments insertObject:[appDelegate.aryComents objectAtIndex:0] atIndex:0];
        [_dataComments addObject:[appDelegate.aryComents objectAtIndex:0]];
        
        [_tvComments reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Action button
- (IBAction)btnBack:(id)sender
{
    isPlayingVideo = NO;
    [self.videoPlayerViewController.moviePlayer stop];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)buttonPressed:(id)sender
{
    if (self.indexOfMenu != [self.menuItemsArray indexOfObject:sender]) {
        self.indexOfMenu = [self.menuItemsArray indexOfObject:sender];
        
        [self refreshMenuBar];
        [self switchTabButton];
    }
}

- (void)switchTabButton
{
    if (self.indexOfMenu == 0) { // Info selected
        [_videoListView.view setHidden:YES];
        _viewInfo.hidden=NO;
        _tvSuggestions.hidden=YES;
        _tvComments.hidden=YES;
        _spinner.hidden=YES;
    } else if(self.indexOfMenu == 1){ // Comment selected
        [_videoListView.view setHidden:YES];
        _viewInfo.hidden=YES;
        _tvSuggestions.hidden=YES;
        _tvComments.hidden=NO;
        [self LoadCommentsIfRequired];
    } else { // Suggestions
        _viewInfo.hidden=YES;
        _tvSuggestions.hidden=NO;
        _tvComments.hidden=YES;
        [self LoadDataIfRequired];
    }
}

#pragma mark Load data
-(void)LoadDataIfRequired
{
    [_videoListView.view setHidden:NO];
}

-(void)LoadCommentsIfRequired
{
    if(_dataComments.count>0)
    {
        _tvComments.hidden=NO;
        _spinner.hidden=YES;
        [_tvComments reloadData];
    } else{
        _tvComments.hidden=NO;
        _spinner.hidden=YES;
    }
}

#pragma mark Table view datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"CommentTableCell";
        
    CommentTableViewCell *cell = (CommentTableViewCell *)[self.tvSuggestions dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
        
    NSDictionary *dic=_dataComments[indexPath.row];
    cell.lblAuthorName.text = [NSString stringWithFormat:@"%@",[dic valueForKey:@"author"]];
    NSString *strTime = [NSString stringWithFormat:@"%@",[dic valueForKey:@"published"]];
    if (strTime.length >= 10) {
        strTime = [strTime substringToIndex:10];
    }
    cell.lblPublishTime.text = strTime;
    NSString *strContent = [NSString stringWithFormat:@"%@",[dic valueForKey:@"content"]];
    strContent = [strContent stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    cell.tvContent.text = strContent;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag==0)
    {
        DetailViewController *vc=[[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        vc.dic=_data[indexPath.row];
        //vc.catTitle=_lblTitle.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag==0)
        return _data.count;
    else
        return _dataComments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag==0)
        return 95;
    else {
        NSStringDrawingContext *ctx = [NSStringDrawingContext new];
        NSString *strContent = [NSString stringWithFormat:@"%@",[_dataComments[indexPath.row] valueForKey:@"content"]];
        strContent = [strContent stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        NSAttributedString *aString = [[NSAttributedString alloc] initWithString:strContent];
        UITextView *calculationView = [[UITextView alloc] init];
        [calculationView setAttributedText:aString];
        CGRect textRect = [calculationView.text boundingRectWithSize:self.view.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:calculationView.font} context:ctx];
       
        return textRect.size.height+40;
    }
}

-(void)loadComments
{
    NSString *url=[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos/%@/comments?v=2&max-results=50",_video.videoId];
    
    dispatch_queue_t ParseQueue = dispatch_queue_create("ParseQueue", NULL);
    dispatch_async(ParseQueue, ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [_dataComments removeAllObjects];
            isCommentEmpty = YES;
            
            NSError *error = nil;
            NSDictionary *dict = [XMLReader dictionaryForXMLData:responseObject
                                                         options:XMLReaderOptionsProcessNamespaces
                                                           error:&error];
            id items = dict[@"feed"][@"entry"];
            if ([items isKindOfClass:[NSArray class]]) {
                for (id item in items) {
                    if([[[item valueForKey:@"content"] valueForKey:@"text"] isEqualToString:@""])
                        continue;
                    NSMutableDictionary *dic=[NSMutableDictionary new];
                    [dic setValue:[[item valueForKey:@"published"]  valueForKey:@"text"] forKey:@"published"];
                    [dic setValue:[[item valueForKey:@"content"] valueForKey:@"text"] forKey:@"content"];
                    [dic setValue:[[[item valueForKey:@"author"] valueForKey:@"name"]  valueForKey:@"text"] forKey:@"author"];
                    [_dataComments addObject:dic];
                }
            } else if([items isKindOfClass:[NSDictionary class]]){
                if(![[[items valueForKey:@"content"] valueForKey:@"text"] isEqualToString:@""]){
                    NSMutableDictionary *dic=[NSMutableDictionary new];
                    [dic setValue:[[items valueForKey:@"published"]  valueForKey:@"text"] forKey:@"published"];
                    [dic setValue:[[items valueForKey:@"content"] valueForKey:@"text"] forKey:@"content"];
                    [dic setValue:[[[items valueForKey:@"author"] valueForKey:@"name"]  valueForKey:@"text"] forKey:@"author"];
                    [_dataComments addObject:dic];
                }
            }
            
            
            if (_dataComments.count <= 0) {
                isCommentEmpty = YES;
            } else {
                isCommentEmpty = NO;
            }
           
            [_tvComments reloadData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
            _spinner.hidden=YES;
        }];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.videoPlayerViewController setPreferredVideoQualities:[[NSArray alloc]initWithObjects:[NSNumber numberWithInt:XCDYouTubeVideoQualitySmall240], nil]];

    [self.videoPlayerViewController.moviePlayer play];
 }

-(NSString*)calDuration:(NSString *)duration{
    @try{
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
    @catch(NSException *e){
        NSLog(@"%@",e);
        
    }
    return duration;
}

- (IBAction)videoLikeDislikeEtc:(id)sender {
    UIButton *btn=(UIButton*)sender;
    BOOL isToContinue=false;
    if(btn.tag!=2)
    {
        isToContinue=[self isToContinue];
    }
    
    if(btn.tag==2)
    {
        [self shareVideo:nil];
    }
    else if(isToContinue)
    {
        switch (btn.tag) {
            case 1:
                [self AddToFav];
                break;
            case 3:
                if(_ivRepeat.tag==0)
                {
                    _ivRepeat.image=[UIImage imageNamed:@"details_repeat_icon_sel.png"];
                    _ivRepeat.tag=1;
                      [self.videoPlayerViewController enableRepeat];
                }
                else{
                    _ivRepeat.image=[UIImage imageNamed:@"details_repeat_icon.png"];
                    _ivRepeat.tag=0;
                    [self.videoPlayerViewController disableRepeat];
                }
                break;
            case 4:
                if(_ivLike.tag==0)
                {
                    _ivLike.image=[UIImage imageNamed:@"details_like_iocn_sel.png"];
                    _ivDisLike.image=[UIImage imageNamed:@"details_dislike_iocn.png"];
                    _ivLike.tag=1;
                    _ivDisLike.tag=0;
                }
                else{
                    _ivLike.image=[UIImage imageNamed:@"details_like_iocn.png"];
                    _ivLike.tag=0;
                    
                }
                
                [self likeDislikeVideo:@"like"];
                break;
            case 5:
                if(_ivDisLike.tag==0)
                {
                    _ivDisLike.image=[UIImage imageNamed:@"details_dislike_iocn_sel.png"];
                    _ivLike.image=[UIImage imageNamed:@"details_like_iocn.png"];
                    _ivDisLike.tag=1;
                    _ivLike.tag=0;
                }
                else{
                    _ivDisLike.image=[UIImage imageNamed:@"details_dislike_iocn.png"];
                    _ivDisLike.tag=0;
                    
                }
                [self likeDislikeVideo:@"dislike"];
                break;
            default:
                break;
        }
    }
    
}

-(void)AddToFav
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Add to"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Watch Later", @"Favorites", @"Add To PlayList", nil];
    [actionSheet showInView:self.view];
}

-(void)AddToFavNW:(NSString*)PlID{
    
    NSString *refresh_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"refresh_token"]];
    if(refresh_token.length>7)
    {
        NSString *access_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"access_token"]];
        
        NSString *cId=_video.videoId;
        cId=[NSString stringWithFormat:@"{\"snippet\": { \"playlistId\": \"%@\",   \"resourceId\": {    \"kind\": \"youtube#video\",    \"videoId\": \"%@\"}}}",PlID,cId];
        
        
        NSString *url=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&access_token=%@",access_token];
        NSURL *ur=[NSURL URLWithString:url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:ur
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
        
        [request setHTTPMethod:@"POST"];
        //        [request setValue:@"Basic: someValue" forHTTPHeaderField:@"Authorization"];
        [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: [cId dataUsingEncoding:NSUTF8StringEncoding]];
        
        dispatch_queue_t ParseQueue = dispatch_queue_create("ParseQueue", NULL);
        dispatch_async(ParseQueue, ^{
            AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            op.responseSerializer = [AFJSONResponseSerializer serializer];
            [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@",error);
            }];
            [op start];
        });
    }
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(popup.tag==1){
        NSArray *preferredVideoQualities;
        switch (buttonIndex) {
            case 0:
                preferredVideoQualities=[[NSArray alloc]initWithObjects:[NSNumber numberWithInt:XCDYouTubeVideoQualitySmall240], nil];
                //[self.btnQuatlity setTitle:@"240p" forState:UIControlStateNormal];
                break;
            case 1:
                preferredVideoQualities=[[NSArray alloc]initWithObjects:[NSNumber numberWithInt:XCDYouTubeVideoQualityMedium360], nil];
                //[self.btnQuatlity setTitle:@"360p" forState:UIControlStateNormal];
                break;
            case 2:
                preferredVideoQualities=[[NSArray alloc]initWithObjects:[NSNumber numberWithInt:XCDYouTubeVideoQualityHD720], nil];
                //[self.btnQuatlity setTitle:@"720p" forState:UIControlStateNormal];
                break;
           default:
                break;
        }
        if(preferredVideoQualities){
            NSTimeInterval current= self.videoPlayerViewController.moviePlayer.currentPlaybackTime;
            [self.videoPlayerViewController setPreferredVideoQualities:preferredVideoQualities];
            [self.videoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:_video.videoId];
            [self.videoPlayerViewController presentInView:self.videoView];
            [self.videoPlayerViewController.moviePlayer setCurrentPlaybackTime:current];
        }
    }
    else{
        switch (buttonIndex) {
            case 0:
                [self AddToFavNW:@"WL"];
                break;
            case 1:
                [self AddToFavNW:@"FLdWRmmcR1HTIY-lu8kWKw5Q"];
                break;
            case 2:
                [self showPlayListView];
                break;
            default:
                break;
                
        }
    }
}

-(void)showPlayListView
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ProTube Clone" message:@"Video Has been Added To Playlist" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

-(void)likeDislikeVideo: (NSString*)type
{
    NSString *access_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"access_token"]];
    NSString *url=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos/rate?&id=%@&rating=%@&access_token=%@",_video.videoId,type,access_token];
    
    dispatch_queue_t ParseQueue = dispatch_queue_create("ParseQueue", NULL);
    dispatch_async(ParseQueue, ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
            _spinner.hidden=YES;
        }];
    });
}

// Open share video
-(void)shareVideo:(id)sender
{
    NSString *strVideoUrl=[NSString stringWithFormat:@"www.youtube.com/watch?v=%@",_video.videoId];
    
    NSMutableArray *shareItems = [NSMutableArray new];
    [shareItems addObject: strVideoUrl];
    NSMutableArray *active = [NSMutableArray array];
    [active addObject:UIActivityTypePostToFacebook];
    UIActivityViewController *shareController =
    [[UIActivityViewController alloc]
     // actual items are prepared by UIActivityItemSource protocol methods below
    
     initWithActivityItems: shareItems
     applicationActivities :nil];
   
    [self presentViewController: shareController animated: YES completion: nil];
    
}

-(BOOL)isToContinue{
    NSString *refresh_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"refresh_token"]];
    if(refresh_token.length>7)
    {
        return true;
    }
    else{
        blockAV *b = [[blockAV alloc] initWithTitle:@"Login Required" message:@"You need to sign in first!" block:^(NSInteger buttonIndex){
            if (buttonIndex == 1)
            {
            }
            
        }
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [b show];
        return false;
    }
}

- (IBAction)btnSubs:(id)sender {
    if([_btnSubs.titleLabel.text isEqualToString:@"Subscribe"]){
        [self subscribe];
    }else{
        [self UnSubscribe];
    }
}

-(void)subscribe
{
    NSString *refresh_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"refresh_token"]];
    if(refresh_token.length>7)
    {
        _AISubs.hidden=NO;
        [_btnSubs setTitle:@"" forState:UIControlStateNormal];
        [_btnSubs setImage:nil forState:UIControlStateNormal];
        
        NSString *access_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"access_token"]];
        
        NSString *cId=[_dic valueForKey:@"channelId"];
        cId=[NSString stringWithFormat:@"{\"snippet\": {    \"resourceId\": {    \"kind\": \"youtube#channel\",    \"channelId\": \"%@\"}}}",self.video.snippet.channelId];
        
        
        NSString *url=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/subscriptions?part=snippet&access_token=%@",access_token];
        NSURL *ur=[NSURL URLWithString:url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:ur
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
        
        [request setHTTPMethod:@"POST"];
        [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: [cId dataUsingEncoding:NSUTF8StringEncoding]];
        
        dispatch_queue_t ParseQueue = dispatch_queue_create("ParseQueue", NULL);
        dispatch_async(ParseQueue, ^{
            AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            op.responseSerializer = [AFJSONResponseSerializer serializer];
            [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                @try {
                    _subsId=[responseObject valueForKey:@"id"];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception);
                }
                [_btnSubs setTitle:@"UnSubscribe" forState:UIControlStateNormal];
                [_btnSubs setImage:[UIImage imageNamed:@"mt_subscribed_icon"] forState:UIControlStateNormal];
                
                _AISubs.hidden=YES;
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@",error);
                _AISubs.hidden=YES;
                [_btnSubs setTitle:@"Subscribe" forState:UIControlStateNormal];
                [_btnSubs setImage:[UIImage imageNamed:@"mt_subscribe_icon"] forState:UIControlStateNormal];
                            }];
            [op start];
        });
    }
    else{
        _AISubs.hidden=YES;
    }
}
-(void)UnSubscribe{
    NSString *refresh_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"refresh_token"]];
    if(refresh_token.length>7)
    {
        _AISubs.hidden=NO;
        [_btnSubs setTitle:@"" forState:UIControlStateNormal];
        [_btnSubs setImage:nil forState:UIControlStateNormal];
        
        NSString *access_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"access_token"]];
        NSString *subID = [[NSUserDefaults standardUserDefaults] objectForKey:self.video.snippet.channelId];
        
        NSString *url=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/subscriptions?id=%@&access_token=%@",subID,access_token];
        NSURL *ur=[NSURL URLWithString:url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:ur
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
        
        [request setHTTPMethod:@"DELETE"];

        dispatch_queue_t ParseQueue = dispatch_queue_create("ParseQueue", NULL);
        dispatch_async(ParseQueue, ^{
            AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            op.responseSerializer = [AFJSONResponseSerializer serializer];
            [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                _AISubs.hidden=YES;
                [_btnSubs setTitle:@"Subscribe" forState:UIControlStateNormal];
                [_btnSubs setImage:[UIImage imageNamed:@"mt_subscribe_icon"] forState:UIControlStateNormal];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@",error);
                _AISubs.hidden=YES;
                [_btnSubs setTitle:@"Subscribe" forState:UIControlStateNormal];
                [_btnSubs setImage:[UIImage imageNamed:@"mt_subscribe_icon"] forState:UIControlStateNormal];

            }];
            [op start];
        });
        
    } else{
        _AISubs.hidden=YES;
    }
}

- (IBAction)addComent:(id)sender {
    
    NSString *strIsName = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"name"]];
    if ([strIsName isEqualToString:@"(null)"]) {
        [[[UIAlertView alloc]initWithTitle:nil message:@"You need to Sign in first!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    } else {
        AddCommentViewController *objComent = [AddCommentViewController new];
        objComent.videoId = _video.videoId;
        [self presentViewController:objComent animated:YES completion:nil];
    }
}

- (void)selectQuanlityVideo:(id)sender {
    //self.btnQuatlity = sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Switch Video Quality"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"240p", @"360p", @"720p", nil];
    [actionSheet setTag:1];
    [actionSheet showInView:[self presentingViewController].view];
}

#pragma mark Homevideo delegate
- (void)homeDidSelectVideo:(CategoryVideo *)video
{
    _video = video;
     [self loadNewVideo];
}

-(void)loadVideoInPlaylist
{
    NSString *playlistID;
    if (self.playlist) {
      playlistID = self.playlist.playlistId;
    }
    else if( self.playlistObject)
    {
        playlistID = self.playlistObject.objectId;
    }
    NSString *url=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlistItems?&part=snippet,contentDetails&playlistId=%@&maxResults=50&key=AIzaSyADMJu_68msQpWhuHv3b3xeodcOpYZCRyI",playlistID];
    videoArrays = [NSMutableArray array];
    dispatch_queue_t ParseQueue = dispatch_queue_create("ParseQueue", NULL);
    dispatch_async(ParseQueue, ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [_dataComments removeAllObjects];
            NSArray *array=[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
 
            NSArray *items = [array valueForKey:@"items"];
            for (id item in items) {
                
                CategoryVideo *video = [[CategoryVideo alloc] init];
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
                    video.videoId = [contentDetail objectForKey:@"videoId"];
                    contentDetails.caption = [contentDetail objectForKey:@"caption"];
                    contentDetails.definition = [contentDetail objectForKey:@"definition"];
                    contentDetails.dimension = [contentDetail objectForKey:@"dimension"];
                    contentDetails.duration = [contentDetail objectForKey:@"duration"];
                    contentDetails.licensedContent = [contentDetail objectForKey:@"licensedContent"];
                    contentDetails.publishAt = [[item objectForKey:@"snippet"] objectForKey:@"publishedAt"];
                    video.contentDetails = contentDetails;
                }
             
//                 Store video item
                [videoArrays addObject:video];
                
        }
            if (videoArrays.count > 0) {
                self.video = [videoArrays objectAtIndex:0];
                [self loadNewVideo];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
            _spinner.hidden=YES;
        }];
    });
}

@end
