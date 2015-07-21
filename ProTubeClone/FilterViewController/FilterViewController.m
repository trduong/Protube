//
//  FilterViewController.m
//  ProTubeClone
//
//  Created by Hoang on 1/17/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "FilterViewController.h"
#import "AppDelegate.h"

#import "OrderFilter.h"
#import "PublishDateFilter.h"
#import "DurationFilter.h"

#define HEIGHT_SECTION  42.0f

@interface FilterViewController ()

@property (strong, nonatomic) NSMutableArray  *orderByArray;
@property (strong, nonatomic) NSMutableArray  *publishDateArray;
@property (strong, nonatomic) NSMutableArray  *durationArray;

@end

@implementation FilterViewController

@synthesize filtetTableView = _filtetTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createDatasource];
    
    // Header table
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_filtetTableView.frame), 10.0f)];
    [header setBackgroundColor:[UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1.0f]];
    _filtetTableView.tableHeaderView = header;
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
- (void)createDatasource
{
    self.orderByArray = [NSMutableArray new];
    self.publishDateArray = [NSMutableArray new];
    self.durationArray = [NSMutableArray new];
    
    // Order
    OrderFilter *order = [[OrderFilter alloc] init];
    order.title = @"Relevance";
    [self.orderByArray addObject:order];
    
    order = [[OrderFilter alloc] init];
    order.title = @"Publish Date";
    [self.orderByArray addObject:order];
    
    order = [[OrderFilter alloc] init];
    order.title = @"View Count";
    [self.orderByArray addObject:order];
    
    order = [[OrderFilter alloc] init];
    order.title = @"Rating";
    [self.orderByArray addObject:order];
    
    // Publish date
    PublishDateFilter *publish = [[PublishDateFilter alloc] init];
    publish.title = @"All";
    [self.publishDateArray addObject:publish];
    
    publish = [[PublishDateFilter alloc] init];
    publish.title = @"Today";
    [self.publishDateArray addObject:publish];
    
    publish = [[PublishDateFilter alloc] init];
    publish.title = @"This Week";
    [self.publishDateArray addObject:publish];
    
    publish = [[PublishDateFilter alloc] init];
    publish.title = @"This Month";
    [self.publishDateArray addObject:publish];
    
    // Duration
    DurationFilter *duration = [[DurationFilter alloc] init];
    duration.title = @"All";
    [self.durationArray addObject:duration];
    
    duration = [[DurationFilter alloc] init];
    duration.title = @"< 4 minutes";
    [self.durationArray addObject:duration];
    
    duration = [[DurationFilter alloc] init];
    duration.title = @"4 ~ 20 minutes";
    [self.durationArray addObject:duration];
    
    duration = [[DurationFilter alloc] init];
    duration.title = @"> 20 minutes";
    [self.durationArray addObject:duration];
    
}

- (AppDelegate*)appDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

#pragma mark TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"filter_cell_identifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"filter_cell_identifier"];
    }
    
    if (indexPath.section == 0) {
        OrderFilter *order = [self.orderByArray objectAtIndex:indexPath.row];
        cell.textLabel.text = order.title;
        
        if (![self appDelegate].orderFilter) {
            if (indexPath.row == 0) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else {
            if ([[self appDelegate].orderFilter.title isEqualToString:order.title]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else if(indexPath.section == 1){
        PublishDateFilter *publish = [self.publishDateArray objectAtIndex:indexPath.row];
        cell.textLabel.text = publish.title;
        
        if (![self appDelegate].publishFilter) {
            if (indexPath.row == 0) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else {
            if ([[self appDelegate].publishFilter.title isEqualToString:publish.title]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
    } else {
        DurationFilter *duration = [self.durationArray objectAtIndex:indexPath.row];
        cell.textLabel.text = duration.title;
        
        if (![self appDelegate].durationFilter) {
            if (indexPath.row == 0) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else {
            if ([[self appDelegate].durationFilter.title isEqualToString:duration.title]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

#pragma mark TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        OrderFilter *order = [self.orderByArray objectAtIndex:indexPath.row];
        [self appDelegate].orderFilter = order;
    } else if(indexPath.section == 1){
        PublishDateFilter *publish = [self.publishDateArray objectAtIndex:indexPath.row];
        [self appDelegate].publishFilter = publish;
    } else {
        DurationFilter *duration = [self.durationArray objectAtIndex:indexPath.row];
        [self appDelegate].durationFilter = duration;
    }
    
    [self.filtetTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEIGHT_SECTION;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0f, CGRectGetWidth(_filtetTableView.frame), HEIGHT_SECTION)];
    [view setBackgroundColor:[UIColor colorWithRed:236/255.0f green:236/255.0f blue:236/255.0f alpha:1.0f]];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, HEIGHT_SECTION - 20.0f - 7.0f, CGRectGetWidth(view.frame) - 16.0f*2, 20.0f)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setFont:[UIFont systemFontOfSize:16.0f]];
    [title setTextColor:[UIColor colorWithRed:123/255.0f green:123/255.0f blue:127/255.0f alpha:1.0f]];
    
    switch (section) {
        case 0:
            [title setText:@"ORDER BY"];
            break;
            
        case 1:
            [title setText:@"PUBLISH DATE"];
            break;
            
        case 2:
            [title setText:@"DURATION"];
            break;
    }
    
    [view addSubview:title];
    
    return view;
}

#pragma mark Action
- (IBAction)cancelSelectRegion:(id)sender
{
    if ([self.filterDelegate respondsToSelector:@selector(filterDidCancel)]) {
        [self.filterDelegate filterDidCancel];
    }
}

- (IBAction)doneSelectRegion:(id)sender
{
    if ([self.filterDelegate respondsToSelector:@selector(filterDidFinshed)]) {
        [self.filterDelegate filterDidFinshed];
    }
}
@end
