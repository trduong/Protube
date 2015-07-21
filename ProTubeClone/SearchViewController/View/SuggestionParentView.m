//
//  SuggestionParentView.m
//  ProTubeClone
//
//  Created by Hoang on 1/31/15.
//  Copyright (c) 2015 Future Work. All rights reserved.
//

#import "SuggestionParentView.h"

@interface SuggestionParentView()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView       *tableView;
@property (strong, nonatomic) NSMutableArray    *datasourceArray;

@end

@implementation SuggestionParentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.datasourceArray = [NSMutableArray new];
        self.clipsToBounds = YES;
        
        [self addSubview:self.tableView];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)resizeViewWithHeight:(CGFloat)height
{
    [UIView animateWithDuration:0.4f animations:^{
        // parent view
        CGRect rect = self.frame;
        rect.size.height = height;
        self.frame = rect;
        
        if (height == 0.0f) {
            [self setHidden:YES];
        } else {
            [self setHidden:NO];
        }
    }];
}

- (void)reloadDatasource:(NSArray*)data
{
    [self.datasourceArray removeAllObjects];
    self.datasourceArray = [NSMutableArray arrayWithArray:data];
    
    [self.tableView reloadData];
}
#pragma mark Getter
- (UITableView*)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 5*40)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.scrollEnabled = NO;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _tableView;
}

#pragma mark Table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasourceArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentify = @"cell_basic";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    cell.textLabel.text = [self.datasourceArray objectAtIndex:indexPath.row];
    
    UIView *separateLine = (UIView*)([cell.contentView viewWithTag:999]);
    if (separateLine) {
        [separateLine removeFromSuperview];
    }
    
    // Separate line
    separateLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 39.0f, CGRectGetWidth(self.tableView.frame), 1.0f)];
    separateLine.tag = 999;
    [separateLine setBackgroundColor:[UIColor colorWithRed:200/255.0f green:199/255.0f blue:204/255.0f alpha:1.0f]];
    [cell.contentView addSubview:separateLine];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate suggestDidSelectItem:[self.datasourceArray objectAtIndex:indexPath.row]];
}
@end
