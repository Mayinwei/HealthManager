//
//  SunBasicTableViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//  基类

#import "SunBasicTableViewController.h"
#import "SunGroupModel.h"
#import "SunMeTabelViewCell.h"
#import "SunBasicModel.h"
#import "SunArrowItemModel.h"

@interface SunBasicTableViewController ()

@end

@implementation SunBasicTableViewController

//懒加载
-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}

//添加组到数组中
-(SunGroupModel *)addToArrayData
{
    SunGroupModel *group=[SunGroupModel group];
    [self.arrayData addObject:group];
    return group;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //去掉分割线
    //self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    //组之间间距
    self.tableView.sectionFooterHeight=5;
    self.tableView.sectionHeaderHeight=5;
}


//设置tableview类型
-(instancetype)initWithStyle:(UITableViewStyle)style
{
    return [super initWithStyle:UITableViewStyleGrouped];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self=[super initWithStyle:UITableViewStyleGrouped];
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.arrayData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SunGroupModel *group=self.arrayData[section];
    return group.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SunMeTabelViewCell *cell=[SunMeTabelViewCell cellWithTableView:tableView];
    SunGroupModel *group=self.arrayData[indexPath.section];
    SunBasicModel *basicMode=group.items[indexPath.row];
    cell.basicModel=basicMode;    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取出模型
    SunGroupModel *group=self.arrayData[indexPath.section];
    SunBasicModel *basicMode=group.items[indexPath.row];
    if (basicMode.operation) {
        basicMode.operation();
    }
    
    //判断是否是箭头类
    if([basicMode isKindOfClass:[SunArrowItemModel class]])
    {
        SunArrowItemModel *arrow=(SunArrowItemModel *)basicMode;
        if (arrow.destVcClass!=nil) {
            UIViewController *vc=[[arrow.destVcClass alloc]init];
            vc.title=arrow.title;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)refreshData
{
    [self.tableView reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SunGroupModel *group=self.arrayData[indexPath.section];
    SunBasicModel *basicMode=group.items[0];
    return basicMode.cellHeight;
}
@end
