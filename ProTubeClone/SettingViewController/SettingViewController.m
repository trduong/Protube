//
//  SettingViewController.m
//  ProTubeClone
//
//  Created by Hoang on 1/30/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "SettingViewController.h"
#import "VideoQuanlityViewController.h"

#import "QuanlityViewCell.h"
#import "VieoBackgroundViewCell.h"

@interface SettingViewController ()

@property (strong, nonatomic) UIBarButtonItem       *backButtonItem;

@end

@implementation SettingViewController
{
    NSArray *_titleSupportsArray;
}

@synthesize backButtonItem = _backButtonItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _titleSupportsArray = @[@"Technical Support", @"Translation Correction", @"Rate the App"];
    
    // Set image button
    self.navigationItem.leftBarButtonItem = self.backButtonItem;
    
    UINib *nib = [UINib nibWithNibName:@"QuanlityViewCell" bundle:nil];
    [self.settingTableView registerNib:nib forCellReuseIdentifier:@"QuanlityCell"];
    
    nib = [UINib nibWithNibName:@"VieoBackgroundViewCell" bundle:nil];
    [self.settingTableView registerNib:nib forCellReuseIdentifier:@"VieoBackgroundViewCell"];
    
    [self.view bringSubviewToFront:self.adsBannerView];
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
- (UIBarButtonItem*)backButtonItem
{
    if (!_backButtonItem) {
        CGRect frame = CGRectMake(0.0f, 0.0f, 30.0f, 30.0f);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        [button setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
    }
    return _backButtonItem;
}
#pragma mark Private methods
- (void)sendMail
{
    // Email Subject
    NSString *emailTitle = @"Protube";
    
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"trongduong1090@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

#pragma mark Table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else {
        return 3;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *videoQualityIdentify = @"QuanlityCell";
            QuanlityViewCell *cell = [tableView dequeueReusableCellWithIdentifier:videoQualityIdentify];
            
            cell.txtLabel.text = [self titleQuanlityVideo];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            return cell;
            
        } else {
            static NSString *allowBackgroundIdentify = @"VieoBackgroundViewCell";
            VieoBackgroundViewCell *cell = [tableView dequeueReusableCellWithIdentifier:allowBackgroundIdentify];
//            
//            CGRect rect = cell.buttonSwitch.frame;
//            rect.origin.x = CGRectGetWidth(cell.frame) - CGRectGetWidth(rect) - 15.0f;
//            cell.buttonSwitch.frame = rect;
        
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
    } else {
        static NSString *basicCellIdentify = @"basic_cell_identify";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:basicCellIdentify];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:basicCellIdentify];
        }
        
        cell.textLabel.text = [_titleSupportsArray objectAtIndex:indexPath.row];
        
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"PLAYER";
            break;
        case 1:
            sectionName = @"SUPPORT";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self moveToQuanlityViewController];
        }
    }
    else {
        if (indexPath.row == 0 || indexPath.row == 1) {
            [self sendMail];
        }
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)moveToQuanlityViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard_iPhone" bundle:[NSBundle mainBundle]];
    VideoQuanlityViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"VideoQuanlityViewController"];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)popViewControllerWithAnimation
{
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.layer addAnimation:transition forKey:@"pop-transition"];
}

#pragma mark Button action
- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backViewController
{
    for (UIViewController *viewController in self.childViewControllers) {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController *navController = (UINavigationController*)viewController;
            [navController willMoveToParentViewController:nil];
            [navController.view removeFromSuperview];
            [navController removeFromParentViewController];
            
            [self popViewControllerWithAnimation];
            
            QuanlityViewCell *cell = (QuanlityViewCell*)[self.settingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell.txtLabel.text = [self titleQuanlityVideo];
            
            break;
        }
    }
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
@end
