//
//  MyVideoListViewController.m
//  ProTubeClone
//
//  Created by Hoang on 1/30/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "MyVideoListViewController.h"
#import "DetailViewController.h"
#import "MyVideoViewCell.h"
#import "NSString+NumberChecking.h"
#import "Videos.h"
#import "CategoryVideo.h"

#import "UIImageView+WebCache.h"

@interface MyVideoListViewController ()

@property (strong, nonatomic) NSMutableArray *videosArray;
@property (nonatomic, copy) NSString *titleCopy;

@property (strong, nonatomic) UIBarButtonItem *backBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *renameBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *editBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *doneBarButtonItem;

@end

@implementation MyVideoListViewController

@synthesize videosArray = _videosArray;
@synthesize txtTitle = _txtTitle;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    _videosArray = [NSMutableArray new];
    
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view bringSubviewToFront:self.adsBannerView];
    
    // Footer table view
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.myVideoTableView.frame), 64.0f)];
    [footer setBackgroundColor:[UIColor clearColor]];
    self.myVideoTableView.tableFooterView = footer;
    
    // Set title
    self.navigationItem.title = _txtTitle;
    self.navigationItem.leftBarButtonItem = self.backBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.editBarButtonItem;
    
    [[SACoreDataManament sharedCoreDataManament] getAllVideosInListName:_txtTitle completion:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (Videos *item in objects) {
                CategoryVideo *video = [[CategoryVideo alloc] init];
                video.videoId = [item valueForKey:@"videoId"];
                
                // Snippet
                Snippet *snippet = [[Snippet alloc] init];
                snippet.channelId = [item valueForKey:@"channelId"];
                snippet.channelTitle = [item valueForKey:@"channelTitle"];
                snippet.descriptionSnippet = [item valueForKey:@"des"];
                snippet.titleSnippet = [item valueForKey:@"title"];
                
                // Statistics
                Statistics *statistics = [[Statistics alloc] init];
                statistics.commentCount = [[item valueForKey:@"commentCount"] integerValue];
                statistics.dislikeCount = [[item valueForKey:@"dislikeCount"] integerValue];
                statistics.favoriteCount = [[item valueForKey:@"favoriteCount"] integerValue];
                statistics.likeCount = [[item valueForKey:@"likeCount"] integerValue];
                statistics.viewCount = [[item valueForKey:@"viewCount"] integerValue];
                
                // Content detail
                ContentDetails *contentDetail = [[ContentDetails alloc] init];
                contentDetail.duration = [item valueForKey:@"duration"];
                contentDetail.publishAt = [item valueForKey:@"publishedAt"];
                
                // Thumbnail
                VideoThumbnail *highThumbnail = [[VideoThumbnail alloc] init];
                highThumbnail.urlThumbnail = [item valueForKey:@"thumbnails"];
                
                snippet.highThumbnail = highThumbnail;
                
                video.snippet = snippet;
                video.statistics = statistics;
                video.contentDetails = contentDetail;
                
                //[newVideo setValue:[NSDate date] forKey:@"date"];
                //[newVideo setValue:@"" forKey:@"type"];
                
                [_videosArray addObject:video];
            }
            
            // Reload table
            [self.myVideoTableView reloadData];
        }
    }];
    
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

- (UIBarButtonItem*)renameBarButtonItem
{
    if (!_renameBarButtonItem) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 65.0f, 26.0f)];
        [button setTitle:@"Rename" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:247/255.0f green:0/255.0f blue:2/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [button addTarget:self action:@selector(renameListAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _renameBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _renameBarButtonItem;
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

#pragma mark Private methods
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
        return [NSString stringWithFormat:@"%02ld:%02ld",(long)minutes ,(long)seconds ];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    }
}

#pragma mark Table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _videosArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentify = @"my_video_cell_identify";
    
    MyVideoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        cell = [[MyVideoViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    
    CategoryVideo *video = [_videosArray objectAtIndex:indexPath.row];
    Snippet *snippet = video.snippet;
    VideoThumbnail *thumbNail = snippet.highThumbnail;
    
    [cell.thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:thumbNail.urlThumbnail] placeholderImage:nil];
    cell.titleLabel.text = snippet.titleSnippet;
    cell.subTitleLabel.text = snippet.descriptionSnippet;
    cell.countLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    
    if (![NSString isNumber:video.contentDetails.duration]) {
        cell.durationLabel.text = [self parseISO8601Time:video.contentDetails.duration];
    } else {
        cell.durationLabel.text = [self formatTimeFromSeconds:[video.contentDetails.duration intValue]];
    }
    
    [cell.durationLabel sizeToFit];
    CGRect rect = cell.durationLabel.frame;
    rect.size.width += 6.0f;
    rect.origin.x = CGRectGetMaxX(cell.thumbnailImageView.frame) - rect.size.width;
    cell.durationLabel.frame = rect;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
         CategoryVideo *video = [_videosArray objectAtIndex:indexPath.row];
        
        [[SACoreDataManament sharedCoreDataManament] deleteVideoInMyList:_txtTitle videoId:video.videoId completion:^(BOOL success, NSError *error) {
            if (success) {
                [_videosArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryVideo *video =_videosArray[indexPath.row];
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
    [self.myVideoTableView setEditing:![self.myVideoTableView isEditing]];
    
    if ([self.myVideoTableView isEditing]) {
        
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem;
        self.navigationItem.leftBarButtonItem = self.renameBarButtonItem;
        
    } else {
        self.navigationItem.rightBarButtonItem = self.editBarButtonItem;
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem;
    }
}

- (IBAction)renameListAction:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Rename" message:@"Enter the playlist name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].text = _txtTitle;
    
    [alert showWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[SACoreDataManament sharedCoreDataManament] renameMyListWithNewName:[alert textFieldAtIndex:0].text oldName:_txtTitle completion:^(BOOL success, NSError *error) {
                if (success) {
                    _txtTitle = [alert textFieldAtIndex:0].text;
                     self.navigationItem.title = _txtTitle;
                    
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:_txtTitle, @"titleList" ,nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateNameList" object:nil userInfo:dict];
                }
            }];
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
@end
