//
//  PlayVideoViewController.m
//  ProTubeClone
//
//  Created by KODY on 1/24/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "PlayYoutubeVideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CategoryVideo.h"
#import "LBYouTubePlayerViewController.h"

@interface PlayYoutubeVideoViewController ()
{
    CategoryVideo *_video;
    LBYouTubePlayerViewController* _controller;
    UIButton *_btCloseView;
}
@end

@implementation PlayYoutubeVideoViewController
- (instancetype)initWithVideo:(CategoryVideo *)video
{
    self = [super init];
    if (self) {
        _btCloseView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        [_btCloseView setTitle:video.snippet.titleSnippet forState:UIControlStateNormal];
        [_btCloseView addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        _video = video;
        
        NSString *urlStr= [NSString stringWithFormat: @"http://www.youtube.com/watch?&v=%@",video.videoId];

        _controller = [[LBYouTubePlayerViewController alloc] initWithYouTubeURL:[NSURL URLWithString:urlStr] quality:LBYouTubeVideoQualityLarge];
        _controller.delegate = self;

 
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(readTime)
                                       userInfo:nil
                                        repeats:YES];
        [_controller.view setFrame:CGRectMake(0, 0, 320, 215)];
        [self.view setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void) readTime
{
    if ([_controller.moviePlayer currentPlaybackTime] > 0) {
        NSLog(@"Curent playing is %f",[_controller.moviePlayer currentPlaybackTime]);
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:_controller.view];
    [self.view addSubview:_btCloseView];

      // Do any additional setup after loading the view.
}

- (void) closeView
{
    _controller = nil;
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void) moviePlayBackDidFinish
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark LBYouTubePlayerViewControllerDelegate

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL {
    //NSLog(@"Did extract video source:%@", videoURL);
}

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller failedExtractingYouTubeURLWithError:(NSError *)error {
    //NSLog(@"Failed loading video due to error:%@", error);
}

#pragma mark -



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
