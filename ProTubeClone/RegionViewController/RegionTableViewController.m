//
//  RegionTableViewController.m
//  ProTubeClone
//
//  Created by Hoang on 1/7/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "RegionTableViewController.h"
#import "AppDelegate.h"
#import "Region.h"
#import "RegionViewCell.h"

@interface RegionTableViewController ()

@property (strong, nonatomic) NSMutableArray    *regionArray;
@property (strong, nonatomic) UIImageView *checkImage;

@end

@implementation RegionTableViewController
{
    NSIndexPath *_previousIndexPath;
    NSIndexPath *_currentIndexPath;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[RegionViewCell class] forCellReuseIdentifier:@"RegionViewCell"];
    
    self.regionArray = [NSMutableArray new];
    
    if ([self appDelegate].indexPathSelected) {
        _currentIndexPath = [self appDelegate].indexPathSelected;
    } else {
        _currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    
    [self loadRegionPlist];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImageView*)checkImage
{
    if(!_checkImage){
        _checkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check"]];
    }
    return _checkImage;
}

#pragma mark Private methods
- (AppDelegate*)appDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void)loadRegionPlist
{
    NSArray *regions = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"regions" ofType:@"plist"]];
    if (regions) {
        NSDictionary *item1 = [regions objectAtIndex:0];
        Region *region = [[Region alloc] init];
        region.nationalFlag = [item1 objectForKey:@"image"];
        region.regionName = [item1 objectForKey:@"name"];
        region.regionCode = [item1 objectForKey:@"regionCode"];
        
        [self.regionArray addObject:region];
        
        NSArray *items = [regions objectAtIndex:1];
        for (id item in items) {
            Region *region = [[Region alloc] init];
            region.nationalFlag = [item objectForKey:@"image"];
            region.regionName = [item objectForKey:@"name"];
            region.regionCode = [item objectForKey:@"regionCode"];
            [self.regionArray addObject:region];
        }
        
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    return self.regionArray.count - 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"RegionViewCell";
    
    RegionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[RegionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        Region *region = [self.regionArray objectAtIndex:0];
        cell.nationImageView.image = [UIImage imageNamed:region.nationalFlag];
        cell.nationNameLabel.text = region.regionName;
        
    } else {
        
        Region *region = [self.regionArray objectAtIndex:indexPath.row + 1];
        cell.nationImageView.image = [UIImage imageNamed:region.nationalFlag];
        cell.nationNameLabel.text = region.regionName;
    }
    
    // Configure the cell...
    if ([_currentIndexPath compare:indexPath] == NSOrderedSame) {
        cell.accessoryView = self.checkImage;
    } else {
        cell.accessoryView = nil;
    }
    
    cell.nationImageView.clipsToBounds = YES;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 35.0f;
    }
    return 25.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _previousIndexPath = _currentIndexPath;
    _currentIndexPath = indexPath;
    [self appDelegate].indexPathSelected = indexPath;
    
    if (indexPath.section == 0) {
        Region *region = [self.regionArray objectAtIndex:0];
        [self appDelegate].regionSelected = region;
    } else {
        Region *region = [self.regionArray objectAtIndex:indexPath.row + 1];
        [self appDelegate].regionSelected = region;
    }

    if ([_currentIndexPath compare:_previousIndexPath] != NSOrderedSame){
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryView = self.checkImage;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_previousIndexPath];
        oldCell.accessoryView = nil;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark Action
- (IBAction)cancelSelectRegion:(id)sender
{
    if ([self.regionDelegate respondsToSelector:@selector(regionCancel)]) {
        [self.regionDelegate regionCancel];
    }
}

- (IBAction)doneSelectRegion:(id)sender
{
    if ([self.regionDelegate respondsToSelector:@selector(regionFinshed)]) {
        [self.regionDelegate regionFinshed];
    }
}
@end
