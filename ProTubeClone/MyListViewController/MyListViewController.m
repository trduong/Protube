//
//  MyListViewController.m
//  ProTubeClone
//
//  Created by Hoang on 1/26/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "MyListViewController.h"
#import "MyVideoListViewController.h"

#import "MyList.h"
#import "MyListPlay.h"

@interface MyListViewController ()

@property (strong, nonatomic) NSMutableArray    *myListArray;
@property (strong, nonatomic) UIBarButtonItem   *leftBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem   *editBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem   *doneBarButtonItem;

@end

@implementation MyListViewController
{
    NSIndexPath *_selectedIndexPath;
    BOOL isEditing;
}

@synthesize myListArray = _myListArray;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayList:) name:NOTIFICATION_UPDATE_MY_LIST_2 object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNameList:) name:@"updateNameList" object:nil];
    
    _myListArray = [[NSMutableArray alloc] init];
    
    [self queryAllListPlay];
     
    return [super initWithCoder:aDecoder];
}
     
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.editBarButtonItem;
    
    [self.view bringSubviewToFront:self.adsBannerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
- (UIBarButtonItem*)leftBarButtonItem
{
    if (!_leftBarButtonItem) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 26.0f, 26.0f)];
        [button setImage:[UIImage imageNamed:@"add_list"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"add_list"] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:@"add_list"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(addNewList:) forControlEvents:UIControlEventTouchUpInside];
        
        _leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _leftBarButtonItem;
}

- (UIBarButtonItem*)editBarButtonItem
{
    if (!_editBarButtonItem) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 35.0f, 26.0f)];
        [button setTitle:@"Edit" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:247/255.0f green:0/255.0f blue:2/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
        [button addTarget:self action:@selector(editList:) forControlEvents:UIControlEventTouchUpInside];
        
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
        [button addTarget:self action:@selector(editList:) forControlEvents:UIControlEventTouchUpInside];
        
        _doneBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _doneBarButtonItem;
}

#pragma mark Private methods
- (void)moveToListVideoWithAnimation:(NSIndexPath*)indexPath;
{
    // Current indexpath
    _selectedIndexPath = indexPath;
    
    MyListPlay *item = [self.myListArray objectAtIndex:indexPath.row];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Storyboard_iPhone" bundle:nil];
    MyVideoListViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"MyVideoListViewController"];
    controller.txtTitle = item.nameList;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark Notification
- (void)updatePlayList:(NSNotification*)aNotification
{
    [self queryAllListPlay];
}

- (void)updateNameList:(NSNotification*)notification
{
    NSDictionary *dict = [notification userInfo];
    NSString *title = dict[@"titleList"];
    
    MyListPlay *obj = [self.myListArray objectAtIndex:_selectedIndexPath.row];
    obj.nameList = title;
    
    UITableViewCell *cell = [self.myListTableView cellForRowAtIndexPath:_selectedIndexPath];
    cell.textLabel.text = title;
}

#pragma mark Table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _myListArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentify = @"MY_LIST_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentify];
    }
    
    MyListPlay *obj = [self.myListArray objectAtIndex:indexPath.row];
    cell.textLabel.text = obj.nameList;
    
    return cell;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        MyListPlay *listObj = [self.myListArray objectAtIndex:indexPath.row];
        [[SACoreDataManament sharedCoreDataManament] deleteMyListWithName:listObj.nameList completion:^(NSError *error) {
            if (!error) {
                [self.myListArray removeObjectAtIndex:indexPath.row];
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
                
                // Notification update
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_MY_LIST object:nil];
            } else {
                [self showAlertWithTitle:nil message:[error localizedDescription]];
            }
        }];
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self moveToListVideoWithAnimation:indexPath];
}
#pragma mark-
/*!
 * Query all list play
 */
- (void)queryAllListPlay
{
    [[SACoreDataManament sharedCoreDataManament] fetchAllMyListWithCompletion:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            [self.myListArray removeAllObjects];
            
            for(MyList *entity in objects){
                MyListPlay *obj = [[MyListPlay alloc] init];
                obj.nameList = entity.nameList;
                
                [self.myListArray addObject:obj];
                
                // Reload table
                [self.myListTableView reloadData];
            }
        } else {
            [self showAlertWithTitle:nil message:[error localizedDescription]];
        }
    }];
}

/*!
 * Show message
 */
- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

#pragma mark Action
- (void)addNewList:(id)sender
{
    if ([self.myListTableView isEditing]) {
        [self.myListTableView setEditing:![self.myListTableView isEditing]];
    }
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Playlist" message:@"Enter the playlist name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert showWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            NSString *name = [alertView textFieldAtIndex:0].text;
            
            [[SACoreDataManament sharedCoreDataManament] saveMyListWithName:name completion:^(NSArray *objects, NSError *error) {
                if (!error) {
                    if (objects.count > 0) {
                        // Alert name list is existed
                        [self showAlertWithTitle:@"Name Exists" message:[NSString stringWithFormat:@"The name \"%@\" already exists. Please choose a different name", name] ];
                        
                    } else {
                        // Show new list
                        [self.myListArray removeAllObjects];
                        [self queryAllListPlay];
                        
                        // Notification update
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_MY_LIST object:nil];
                    }
                } else {
                    [self showAlertWithTitle:nil message:[error localizedDescription]];
                }
            }];
        }
    }];
}

- (void)editList:(id)sender
{
    [self.myListTableView setEditing:![self.myListTableView isEditing]];
    
    if ([self.myListTableView isEditing]) {
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem;
    } else {
        self.navigationItem.rightBarButtonItem = self.editBarButtonItem;
    }
}

@end
