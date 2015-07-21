//
//  VideoQuanlityViewController.m
//  ProTubeClone
//
//  Created by Hoang on 3/9/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "VideoQuanlityViewController.h"

#define CELL_IDENTIFIER @"quanlity_cell"

@interface VideoQuanlityViewController ()

@property (strong, nonatomic) UIBarButtonItem       *backButtonItem;
@property (strong, nonatomic) UIBarButtonItem   *leftBarItem;
@property (strong, nonatomic) UIImageView *checkImage;

@end

@implementation VideoQuanlityViewController
{
    NSArray *titles;
    
    NSIndexPath *_currentIndexPath;
    NSIndexPath *_previousIndexPath;
    
    NSString *_titleSelected;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    titles = @[@"240p", @"360p", @"720p", @"1080p"];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *quanlity = [userDefault objectForKey:@"quanlity"];
    if (!quanlity) {
        _currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    } else {
        if ([quanlity isEqualToString:@"240p"]) {
            _currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        } else if([quanlity isEqualToString:@"360p"]){
            _currentIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        } else if([quanlity isEqualToString:@"720p"]){
            _currentIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        } else {
            _currentIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
        }
    }
    
    _titleSelected = [titles objectAtIndex:_currentIndexPath.row];
    
    return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = self.leftBarItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Video Quanlity";
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
- (UIBarButtonItem*)leftBarItem
{
    if (!_leftBarItem) {
        UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 24)];
        [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateSelected];
        [button setImage:[UIImage imageNamed:@"back"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(backActionPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _leftBarItem;
}

- (UIImageView*)checkImage
{
    if(!_checkImage){
        _checkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check"]];
    }
    return _checkImage;
}

#pragma mark - Table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    cell.textLabel.text = [titles objectAtIndex:indexPath.row];
    
    if ([_currentIndexPath compare:indexPath] == NSOrderedSame) {
        cell.accessoryView = self.checkImage;
    } else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _previousIndexPath = _currentIndexPath;
    _currentIndexPath = indexPath;
    
    _titleSelected = [titles objectAtIndex:indexPath.row];
    
    if ([_currentIndexPath compare:_previousIndexPath] != NSOrderedSame){
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryView = self.checkImage;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_previousIndexPath];
        oldCell.accessoryView = nil;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Save
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:_titleSelected forKey:@"quanlity"];
        [userDefault synchronize];
    }
    
}
#pragma mark - Action
- (void)backActionPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
