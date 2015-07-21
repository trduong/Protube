//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "LeftMenuViewController.h"

#import <AFHTTPRequestOperationManager.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "HomeViewController.h"
#import "UIImageView+WebCache.h"
#import <GooglePlus/GooglePlus.h>

#import "InfoUser.h"
#import "UIViewController+MMDrawerController.h"
#import "HomeViewController.h"

#import "MenuItemExpandableCell.h"
#import "SignInExpandabkeViewCell.h"
#import "MenuItemViewCell.h"
#import "SignoutExpandableCell.h"
#import "AppDelegate.h"


@interface LeftMenuViewController(){
    NSMutableArray *_categories;
    UIActivityIndicatorView *_loading;
    GPPSignIn *signIn;
    NSString *kClientId;
    NSString *token;
    NSMutableArray      *sectionTitleArray;
    NSMutableDictionary *sectionContentDict;
    NSMutableArray      *arrayForBool;
    
    InfoUser * _infoUser;
    
    BOOL isDefaultSelected;
    
    NSString *_pageToken;
}

@property (nonatomic, strong) NSMutableArray * firstSectionItems;
@property (nonatomic, strong) NSMutableArray * secondSectionItems;
@property (nonatomic, strong) NSMutableArray * thirdSectionItems;
@property (nonatomic, strong) NSArray * titleSectionItems;

@property (nonatomic, strong) NSMutableArray * sectionsArray;

@property (nonatomic, strong) NSMutableIndexSet *expandableSections;

@end

NSString * const kGTLAuthScopeYouTube                          = @"https://www.googleapis.com/auth/youtube";
NSString * const kGTLAuthScopeYouTubeReadonly                  = @"https://www.googleapis.com/auth/youtube.readonly";
NSString * const kGTLAuthScopeYouTubeUpload                    = @"https://www.googleapis.com/auth/youtube.upload";
NSString * const kGTLAuthScopeYouTubeYoutubepartner            = @"https://www.googleapis.com/auth/youtubepartner";
NSString * const kGTLAuthScopeYouTubeYoutubepartnerChannelAudit = @"https://www.googleapis.com/auth/youtubepartner-channel-audit";

@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -
- (id)initWithCoder:(NSCoder *)aDecoder
{
    kClientId = @"118110160873-geh74g46sblbpbt7ifdmjakdmvb6ii44.apps.googleusercontent.com";
    isDefaultSelected = YES;
    self.slideOutAnimationEnabled = YES;
    _categories = [NSMutableArray array];
    
    NSString *tokenCached =  [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if (tokenCached.length > 1) {
        [signIn trySilentAuthentication];
    }
    token = [GPPSignIn sharedInstance].authentication.accessToken;
    _pageToken = @"";
    
    //Login
    signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    
    // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = [NSArray arrayWithObjects:
                     kGTLAuthScopePlusLogin, kGTLAuthScopeYouTubeYoutubepartner, kGTLAuthScopeYouTube,
                     kGTLAuthScopeYouTubeUpload,
                     nil];
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    

    return [super initWithCoder:aDecoder];
}

- (void)getContentItems
{
    [signIn authenticate];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    
   // NSLog(@"Received error %@ and auth object %@",error, auth);
    if (auth.accessToken) {
        
        isPlayingVideo = NO;
        isLogged = YES;
        isDefaultSelected = NO;
        
        [[NSUserDefaults standardUserDefaults] setValue:auth.accessToken forKey:@"refresh_token"];
        [[NSUserDefaults standardUserDefaults] setValue:auth.accessToken forKey:@"access_token"];
        
        GTLPlusPerson *person = [GPPSignIn sharedInstance].googlePlusUser;
        GTLPlusPersonEmailsItem *email = [person.emails objectAtIndex:0];
        GTLPlusPersonImage *imageUser = person.image;
        
        // Info user
        _infoUser = [[InfoUser alloc] init];
        _infoUser.userName = person.displayName;
        _infoUser.email = email.value;
        _infoUser.urlImage = imageUser.url;
        
        [[NSUserDefaults standardUserDefaults] setObject:person.displayName forKey:@"name"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/channels?&part=contentDetails&mine=true&maxResults=%@&access_token=%@&pageToken=%@",@"30",auth.accessToken,@""];
        dispatch_queue_t ParseQueue = dispatch_queue_create("ParseQueue", NULL);
        
        dispatch_async(ParseQueue, ^{
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSArray *array=[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                NSArray *arr=[array valueForKey:@"items"];
                id contentDetail = [arr[0]  objectForKey:@"contentDetails"];
                
                NSString *favoriteID = contentDetail[@"relatedPlaylists"][@"favorites"];

                [[NSUserDefaults standardUserDefaults] setObject:favoriteID forKey:@"FAVORITE_ID"];
                
                NSString *playlistItemsString = [NSString stringWithFormat:@"%@,%@,%@", contentDetail[@"relatedPlaylists"][@"watchHistory"], contentDetail[@"relatedPlaylists"][@"likes"], contentDetail[@"relatedPlaylists"][@"watchLater"]];
                [self appDelegate].playlistItems = playlistItemsString;
                

                MenuItem *item = [[MenuItem alloc] init];
                item.titleMenu = @"Subscriptions";
                item.imageName = @"subscriptions";
                item.menuId = contentDetail[@"relatedPlaylists"][@"likes"];
                item.isKindChannel = YES;
                item.orderItem = 0;
                [_firstSectionItems addObject:item];
                
                item = [[MenuItem alloc] init];
                item.titleMenu = @"What to Watch";
                item.imageName = @"recommended";
                item.menuId = contentDetail[@"relatedPlaylists"][@"watchHistory"];
                item.isKindChannel = YES;
                item.orderItem = 1;
                [_firstSectionItems addObject:item];
                
                item = [[MenuItem alloc] init];
                item.titleMenu = @"Favorites";
                item.imageName = @"favorites";
                item.menuId = contentDetail[@"relatedPlaylists"][@"favorites"];
                item.isKindChannel = YES;
                item.orderItem = 2;
                [_firstSectionItems addObject:item];
                
                item = [[MenuItem alloc] init];
                item.titleMenu = @"Watch Later";
                item.imageName = @"watch_later";
                item.menuId = contentDetail[@"relatedPlaylists"][@"watchLater"];
                item.isKindChannel = YES;
                item.orderItem = 3;
                [_firstSectionItems addObject:item];
                
                item = [[MenuItem alloc] init];
                item.titleMenu = @"Playlists";
                item.imageName = @"my_playlists";
                item.menuId = contentDetail[@"relatedPlaylists"][@"uploads"];
                item.isKindChannel = YES;
                item.orderItem = 4;
                [_firstSectionItems addObject:item];
                
                NSString *urlSubcription=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/subscriptions?part=snippet,contentDetails,subscriberSnippet&mine=true&maxResults=%@&access_token=%@&pageToken=%@",@"30",auth.accessToken,@""];
                dispatch_queue_t ParseQueueSup = dispatch_queue_create("ParseQueueSup", NULL);
                
                dispatch_async(ParseQueueSup, ^{
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                    [manager GET:urlSubcription parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        id result = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                        _pageToken = [result objectForKey:@"nextPageToken"];
                        
                        NSArray *items=[result valueForKey:@"items"];
                        _categories = [NSMutableArray array];
                        
                        for (id item in items) {
                            
                            [[NSUserDefaults standardUserDefaults] setObject:item[@"id"] forKey:item[@"snippet"][@"resourceId"][@"channelId"]];
                            
                            MenuItem *itemMenu = [[MenuItem alloc] init];
                            itemMenu.titleMenu = item[@"snippet"][@"title"];
                            itemMenu.menuId = item[@"snippet"][@"resourceId"][@"channelId"];
                            itemMenu.subsciptionId = item[@"id"];
                            itemMenu.imageName = item[@"snippet"][@"thumbnails"][@"default"][@"url"];
                            itemMenu.isKindSubscription = YES;
                            
                            [_secondSectionItems addObject:itemMenu];
                        }
                        
                        [_secondSectionItems sortUsingComparator:^(MenuItem *firstObject, MenuItem *secondObject) {
                            return [firstObject.titleMenu caseInsensitiveCompare:secondObject.titleMenu];
                        }];
                        
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        _sectionsArray = @[ _firstSectionItems, _secondSectionItems, _thirdSectionItems ].mutableCopy;
                        _titleSectionItems = @[@"SUBSCRIPTIONS", @"CATEGORIES"];
                        
                        NSArray *dataArray = self.sectionsArray[0];
                        MenuItem *item = dataArray[0];
                        
                        [self switchMenuWithMenuItem:item];

                        [self.tableView reloadData];
                        
                        for (int i = 0; i < _sectionsArray.count; i++) {
                            [self.tableView expandSection:i animated:NO];
                        }
                        
                        if (_pageToken) {
                            [self loadListSubcriptionWithAccessToken:auth.accessToken];
                        }
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"%@",error);
                    }];
                });
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@",error);
            }];
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:33/255.0f green:33/255.0f blue:33/255.0f alpha:1.0f]];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:33/255.0f green:33/255.0f blue:33/255.0f alpha:1.0f]];
    
    // Expand menu
    if (!signIn.authentication.accessToken) {
        [self.tableView expandSection:1 animated:NO];
    } else {
        [self.tableView expandSection:2 animated:NO];
    }
    
    [self generateMenuItem];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:animated];
}

- (AppDelegate*)appDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void)generateMenuItem
{
    // The third section
    self.thirdSectionItems = [[NSMutableArray alloc] init];
    _firstSectionItems = [[NSMutableArray alloc] init];
    _secondSectionItems = [[NSMutableArray alloc] init];
    
    // 1. Autos & Vehicles
    MenuItem *item = [[MenuItem alloc] init];
    item.titleMenu = @"Autos & Vehicles";
    item.imageName = @"Autos";
    item.menuId = @"2";
    [self.thirdSectionItems addObject:item];
    
    // 2. Comedy
    item = [[MenuItem alloc] init];
    item.titleMenu = @"Comedy";
    item.imageName = @"Comedy";
    item.menuId = @"23";
    [self.thirdSectionItems addObject:item];
    
    // 3. Education
    item = [[MenuItem alloc] init];
    item.titleMenu = @"Education";
    item.imageName = @"Education";
    item.menuId = @"27";
    [self.thirdSectionItems addObject:item];
    
    // 1. Entertainment
    item = [[MenuItem alloc] init];
    item.titleMenu = @"Entertainment";
    item.imageName = @"Entertainment";
    item.menuId = @"24";
    [self.thirdSectionItems addObject:item];
    
    // 1. Film & Animation
    item = [[MenuItem alloc] init];
    item.titleMenu = @"Film & Animation";
    item.imageName = @"Film";
    item.menuId = @"1";
    [self.thirdSectionItems addObject:item];
    
    // 1. Gaming
    item = [[MenuItem alloc] init];
    item.titleMenu = @"Gaming";
    item.imageName = @"Games";
    item.menuId = @"20";
    [self.thirdSectionItems addObject:item];
    
    // 1. Howto & Style
    item = [[MenuItem alloc] init];
    item.titleMenu = @"Howto & Style";
    item.imageName = @"Howto";
    item.menuId = @"26";
    [self.thirdSectionItems addObject:item];
    
    // 1. Music
    item = [[MenuItem alloc] init];
    item.titleMenu = @"Music";
    item.imageName = @"Music";
    item.menuId = @"10";
    [self.thirdSectionItems addObject:item];
    
    // 1. News & Politics
    item = [[MenuItem alloc] init];
    item.titleMenu = @"News & Politics";
    item.imageName = @"News";
    item.menuId = @"25";
    [self.thirdSectionItems addObject:item];
    
    // 1. Nonprofits & Activism
    item = [[MenuItem alloc] init];
    item.titleMenu = @"Nonprofits & Activism";
    item.imageName = @"Nonprofit";
    item.menuId = @"29";
    [self.thirdSectionItems addObject:item];
    
    // 1. People & Blog
    item = [[MenuItem alloc] init];
    item.titleMenu = @"People & Blog";
    item.imageName = @"People";
    item.menuId = @"22";
    [self.thirdSectionItems addObject:item];
    
    // 1. Pets & Animals
    item = [[MenuItem alloc] init];
    item.titleMenu = @"Pets & Animals";
    item.imageName = @"Animals";
    item.menuId = @"15";
    [self.thirdSectionItems addObject:item];
    
    // 1. Science & Technology
    item = [[MenuItem alloc] init];
    item.titleMenu = @"Science & Technology";
    item.imageName = @"Tech";
    item.menuId = @"28";
    [self.thirdSectionItems addObject:item];
    
    // 1. Sports
    item = [[MenuItem alloc] init];
    item.titleMenu = @"Sports";
    item.imageName = @"Sports";
    item.menuId = @"17";
    [self.thirdSectionItems addObject:item];
    
    // 1. Travel & Events
    item = [[MenuItem alloc] init];
    item.titleMenu = @"Travel & Events";
    item.imageName = @"Travel";
    item.menuId = @"19";
    [self.thirdSectionItems addObject:item];
    
    if (!signIn.authentication.accessToken) {
        _titleSectionItems = @[@"CATEGORIES"];
        _sectionsArray = @[ _firstSectionItems, _thirdSectionItems ].mutableCopy;
    } else {
        _sectionsArray = @[ _firstSectionItems, _secondSectionItems, _thirdSectionItems ].mutableCopy;
        _titleSectionItems = @[@"SUBSCRIPTIONS", @"CATEGORIES"];
    }
    
    _expandableSections = [NSMutableIndexSet indexSet];

}

- (void)getCateoryList
{
    NSString *url = @"https://www.googleapis.com/youtube/v3/videoCategories?part=snippet&regionCode=US&key=AIzaSyADMJu_68msQpWhuHv3b3xeodcOpYZCRyI&pageToken=";
    
    dispatch_queue_t ParseQueue = dispatch_queue_create("ParseQueue", NULL);
    dispatch_async(ParseQueue, ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *array=[NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            _categories = [NSMutableArray array];
            NSArray *arr=[array valueForKey:@"items"];
            for (NSArray *ar in arr) {
                NSMutableDictionary *dic=[NSMutableDictionary new];
                [dic setValue:[ar valueForKey:@"id"] forKey:@"id"];
                [dic setValue:
                 [ [ar valueForKey:@"snippet"] valueForKey:@"title"]
                       forKey:@"title"] ;
                [_categories addObject:dic];
            }
            
            NSArray *array2     = _categories;
            [sectionContentDict setValue:array2 forKey:[sectionTitleArray objectAtIndex:1]];
            
            [self.tableView reloadSectionIndexTitles];
            [self.tableView reloadData];
            NSString *refresh_token=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"refresh_token"]];
            
            if (![refresh_token isEqualToString:@"(null)"]) {
                [signIn authenticate];
            }

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
    });
}

#pragma mark-
- (void)signOut
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sign Out" message:@"Are you sure to sign out?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign Out", nil];
    [alertView showWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            isLogged = NO;
            signIn.authentication.accessToken = nil;
            [signIn signOut];
            
            [self generateMenuItem];
            
            [self.tableView reloadData];
            [self.tableView expandSection:1 animated:NO];
        }
    }];
}

- (void)switchMenuWithMenuItem:(MenuItem*)item
{
    isSelectedFromMenu = YES;
    isPlayingVideo = NO;
    
    UINavigationController *nav = [[self appDelegate].centerViewController viewControllers][0];
    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray:nav.viewControllers];
    if (navigationArray.count > 1) {
        [navigationArray removeObjectAtIndex:1];
    }
    
    HomeViewController *homeVC = [nav viewControllers][0];
    [homeVC loadContentWithItem:item];
    
    nav.viewControllers = navigationArray;
    
    [[self appDelegate].centerViewController setSelectedIndex:0];
    
    [self.mm_drawerController
     setCenterViewController:[self appDelegate].centerViewController
     withCloseAnimation:YES
     completion:nil];
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    MenuItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MenuItemViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSArray *dataArray = self.sectionsArray[indexPath.section];
    MenuItem *item = dataArray[indexPath.row - 1];
    
    cell.textLabel.text = item.titleMenu;
    
    if (isLogged) {
        if (indexPath.section == 1) {
            cell.needResizeImageView = YES;
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:item.imageName] placeholderImage:nil];
        } else {
            cell.needResizeImageView = NO;
            cell.imageView.image = [UIImage imageNamed:item.imageName];
        }
    } else {
        cell.needResizeImageView = NO;
        cell.imageView.image = [UIImage imageNamed:item.imageName];
    }
    
    if (isDefaultSelected) {
        if (indexPath.row == 4) {
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = [UIColor colorWithRed:23/255.0f green:23/255.0f blue:23/255.0f alpha:1.0f];
    cell.selectedBackgroundView = myBackView;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (!signIn.authentication.accessToken) {
            [signIn authenticate];
            return;
        }
        
    }
    
    if (indexPath.row > 0) {
        isDefaultSelected = NO;
        
        
        NSArray *dataArray = self.sectionsArray[indexPath.section];
        MenuItem *item = dataArray[indexPath.row - 1];

        [self switchMenuWithMenuItem:item];
    }
}


#pragma mark - gesture tapped
- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    if (indexPath.row == 0) {
        BOOL collapsed  = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
        collapsed       = !collapsed;
        [arrayForBool replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithBool:collapsed]];
        
        //reload specific section animated
        NSRange range   = NSMakeRange(indexPath.section, 1);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - SLExpandableTableViewDatasource

- (BOOL)tableView:(SLExpandableTableView *)tableView canExpandSection:(NSInteger)section
{
    return YES;
}

- (BOOL)tableView:(SLExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section
{
    return NO;
}

- (void)tableView:(SLExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.expandableSections addIndex:section];
        [tableView expandSection:section animated:YES];
    });
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(SLExpandableTableView *)tableView expandingCellForSection:(NSInteger)section
{
    if (section == 0) {
        if (!isLogged) {
            static NSString *CellIdentifier = @"SigInExpandable";
            SignInExpandabkeViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[SignInExpandabkeViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            return cell;
        } else {
            static NSString *CellIdentifier = @"SigOutExpandable";
            SignoutExpandableCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[SignoutExpandableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:_infoUser.urlImage] placeholderImage:nil];
            cell.userNameLabel.text = _infoUser.userName;
            cell.emailLabel.text = _infoUser.email;
            
            [cell setDidSelectSignOutBlock:^(id sender) {
                [self signOut];
            }];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            return cell;
        }
        
        
    } else {
        static NSString *CellIdentifier = @"SLExpandableTableViewControllerHeaderCell";
        MenuItemExpandableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[MenuItemExpandableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = _titleSectionItems[section - 1];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    }
    
}

#pragma mark - SLExpandableTableViewDelegate

- (void)tableView:(SLExpandableTableView *)tableView didCollapseSection:(NSUInteger)section animated:(BOOL)animated
{
    [self.expandableSections removeIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0 && indexPath.row == 0) {
        return 25.0f;
    }
    return 53.0f;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dataArray = self.sectionsArray[section];
    return dataArray.count + 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.sectionsArray removeObjectAtIndex:indexPath.section];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - API
- (void)loadListSubcriptionWithAccessToken:(NSString*)accessToken
{
    NSString *urlSubcription=[NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/subscriptions?part=snippet,contentDetails,subscriberSnippet&mine=true&maxResults=%@&access_token=%@&pageToken=%@",@"30",accessToken,_pageToken];
    dispatch_queue_t ParseQueueSup = dispatch_queue_create("ParseQueueSup", NULL);
    
    dispatch_async(ParseQueueSup, ^{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:urlSubcription parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            id result = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            _pageToken = [result objectForKey:@"nextPageToken"];
            
            NSArray *items=[result valueForKey:@"items"];
            _categories = [NSMutableArray array];
            
            for (id item in items) {
                
                MenuItem *itemMenu = [[MenuItem alloc] init];
                itemMenu.titleMenu = item[@"snippet"][@"title"];
                itemMenu.menuId = item[@"snippet"][@"resourceId"][@"channelId"];
                itemMenu.imageName = item[@"snippet"][@"thumbnails"][@"default"][@"url"];
                itemMenu.isKindSubscription = YES;
                
                [_secondSectionItems addObject:itemMenu];
                
            }
            
            [self.tableView reloadData];
            
            if (_pageToken) {
                [self loadListSubcriptionWithAccessToken:accessToken];
            }
            
            for (int i = 0; i < _sectionsArray.count; i++) {
                [self.tableView expandSection:i animated:NO];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
    });
}
@end
