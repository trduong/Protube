//
//  DetailViewController.h
//  ProTubeClone
//
//  Created by Apple on 18/08/14.
//  Copyright (c) 2014 Future Work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@class AppDelegate;
@class CategoryVideo;
@class XCDYouTubeVideoPlayerViewController;
@class PlaylistObject;


@interface DetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, HomeDelegate>
{
    AppDelegate *appDelegate;
}

@property (strong, nonatomic) IBOutlet UIView *videoView;

@property (strong, nonatomic) IBOutlet UILabel *lblLikeDislike;
@property (strong, nonatomic) IBOutlet UILabel *lblVideoTitle;
@property (strong, nonatomic) IBOutlet UIScrollView *viewInfo;
@property (strong, nonatomic) IBOutlet UILabel *lblFav;
@property (strong, nonatomic) IBOutlet UITextView *tvDescription;

@property (strong, nonatomic) IBOutlet UIProgressView *pvLikeDislikes;
@property (strong, nonatomic) IBOutlet UILabel *lblChannelTitle;

@property (strong, nonatomic) IBOutlet UITableView *tvSuggestions;
@property (strong, nonatomic) IBOutlet UILabel *lblPublishedAt;
@property (strong, nonatomic) IBOutlet UIImageView *ivChannelLogo;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) IBOutlet UIImageView *ivDisLike;
@property (strong, nonatomic) IBOutlet UIImageView *ivRepeat;
@property (strong, nonatomic) IBOutlet UIView *tabarMenu;
@property (strong, nonatomic) IBOutlet UIView *playMenu;

@property (strong, nonatomic) IBOutlet UIImageView *ivLike;

@property (strong, nonatomic) IBOutlet UIButton *btnSubs;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *AISubs;
@property (strong, nonatomic) IBOutlet UIImageView *ivSubs;
@property (strong, nonatomic) IBOutlet UITableView *tvComments;
@property (strong, nonatomic) IBOutlet UIView *tabView;

@property (strong, nonatomic) IBOutlet UIButton *addMoreComment;

@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) NSMutableArray *dataComments;
@property (strong, nonatomic) NSMutableArray *aryTvHeight;
@property (strong, nonatomic) NSDictionary *dic;

@property (strong, nonatomic) NSString *catTitle;
@property (strong, nonatomic) NSString *subsId;
@property (strong, nonatomic) NSString *viewType;

@property (strong, nonatomic) CategoryVideo *video;
@property (strong, nonatomic) PlayListSearch *playlist;
@property (strong, nonatomic) PlaylistObject *playlistObject;

@property (strong, nonatomic) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

- (void)loadNewVideo;

- (IBAction)addComent:(id)sender;
- (IBAction)videoLikeDislikeEtc:(id)sender;
- (IBAction)btnSubs:(id)sender;

@end
