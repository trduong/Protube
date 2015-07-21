//
//  MoreViewController.m
//  ProTubeClone
//
//  Created by Hoang on 1/28/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "MoreViewController.h"
#import "HistoryViewController.h"
#import "SettingViewController.h"

@interface MoreViewController ()

@property (strong, nonatomic) NSArray   *titlesArray;
@property (strong, nonatomic) NSArray  *iconsArray;

@end

@implementation MoreViewController

@synthesize titlesArray = _titlesArray;
@synthesize iconsArray = _iconsArray;
@synthesize moreTableView = _moreTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titlesArray = @[@"History", @"Settings"];
    _iconsArray = @[@"history", @"setting"];
    
    [self.navigationController.navigationBar setTranslucent:NO];
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

#pragma mark Private methods
- (void)moveToHistoryWithAnimation
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard_iPhone" bundle:[NSBundle mainBundle]];
    HistoryViewController *historyController = [storyBoard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
    
    [self.navigationController pushViewController:historyController animated:YES];
}

- (void)moveToSettingViewControllerWithAnimation
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard_iPhone" bundle:nil];
    SettingViewController *settingController = [storyBoard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    [self.navigationController pushViewController:settingController animated:YES];
}

- (void)popViewControllerWithAnimation
{
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.layer addAnimation:transition forKey:@"pop-transition"];
}

- (void)removeChildViewController
{
    // Clear content
    for (UIViewController *VC in self.childViewControllers) {
        
        if ([VC isKindOfClass:[HistoryViewController class]]) {
            HistoryViewController *historyController = (HistoryViewController*)VC;
            [historyController willMoveToParentViewController:nil];
            [historyController.view removeFromSuperview];
            [historyController removeFromParentViewController];
            
            [self popViewControllerWithAnimation];
            
            historyController = nil;
            
            break;
        }
        
        if ([VC isKindOfClass:[SettingViewController class]]) {
            SettingViewController *settingController = (SettingViewController*)VC;
            [settingController willMoveToParentViewController:nil];
            [settingController.view removeFromSuperview];
            [settingController removeFromParentViewController];
            
            [self popViewControllerWithAnimation];
            
            settingController = nil;
            
            break;
        }
    }
}

#pragma mark Table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        static NSString *identify = @"history_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
        
    } else {
        static NSString *identify = @"setting_cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
    }
    
    
    cell.textLabel.text = [_titlesArray objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[_iconsArray objectAtIndex:indexPath.row]];
    
    // Remove separate line
    UIView *view = (UIView*)[cell.contentView viewWithTag:99];
    if (view) {
        [view removeFromSuperview];
    }
    
    // Add separate line
    view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(cell.imageView.frame), 67.0f - 1.0f, CGRectGetWidth(_moreTableView.frame) - CGRectGetMinX(cell.imageView.frame), 1.0f)];
    [view setBackgroundColor:[UIColor colorWithRed:200/255.0f green:199/255.0f blue:204/255.0f alpha:1.0f]];
    view.tag = 99;
    
    [cell.contentView addSubview:view];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67.0f;
}

#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self moveToHistoryWithAnimation];
    } else {
        [self moveToSettingViewControllerWithAnimation];
    }
}

#pragma mark Delegate
- (void)backViewController
{
    [self removeChildViewController];
}

@end
