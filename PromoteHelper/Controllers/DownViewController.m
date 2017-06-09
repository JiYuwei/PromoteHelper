//
//  DownViewController.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/1/26.
//  Copyright © 2016年 willing. All rights reserved.
//

#import "DownViewController.h"


@interface DownViewController ()

@end


@implementation DownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.view.backgroundColor=[UIColor whiteColor];
    
    [self createTopView];
    [self prepareData];
    [self createTableView];
}

-(void)customSectionTitle
{
    _sectionArr=@[@"",@""];
}

-(void)createTopView
{
    [self customSectionTitle];
    _sectionHeight=40;
    
    _topView=[[SectionHeaderCatgoryView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, _sectionHeight)];
    [_topView setSectionHeaderCategories:_sectionArr];
    _topView.delegate=self;
    
    [self.view addSubview:_topView];
}


-(void)prepareData
{
    _dataArray=[[NSMutableArray alloc] init];
    for (int i=0; i<_sectionArr.count; i++) {
        [_dataArray addObject:[[NSMutableArray alloc] init]];
    }
    
    [self retrieveData];
}


-(void)retrieveData
{
    
}

-(void)createTableView
{
    _mainView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, _sectionHeight, self.view.bounds.size.width, self.view.bounds.size.height-_sectionHeight-64)];
//    _mainView.backgroundColor=[UIColor redColor];
    _mainView.contentSize=CGSizeMake(self.view.bounds.size.width*_sectionArr.count, self.view.bounds.size.height-_sectionHeight-64);
    _mainView.pagingEnabled=YES;
    _mainView.showsHorizontalScrollIndicator=NO;
    _mainView.delegate=self;
    
    [self.view addSubview:_mainView];
    
    _tableViews=[[NSMutableArray alloc] init];
    
    for (int i=0; i<_sectionArr.count; i++) {
        UITableView *tableView=[[UITableView alloc] initWithFrame:CGRectMake(_mainView.frame.size.width*i, 0, _mainView.frame.size.width, _mainView.frame.size.height) style:UITableViewStyleGrouped];
        tableView.backgroundColor=[UIColor clearColor];
        tableView.dataSource=self;
        tableView.delegate=self;
        tableView.header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self retrieveData];
        }];
        [tableView registerNib:[UINib nibWithNibName:@"DownPeopleCell" bundle:nil] forCellReuseIdentifier:@"DownPeoCell"];
        [_mainView addSubview:tableView];
        
        UILabel *emptyLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        emptyLabel.center=CGPointMake(tableView.frame.size.width/2, tableView.frame.size.height/2);
        emptyLabel.font=[UIFont boldSystemFontOfSize:20];
        emptyLabel.textAlignment=NSTextAlignmentCenter;
        emptyLabel.textColor=[UIColor lightGrayColor];
        emptyLabel.text=@"无内容";
        emptyLabel.hidden=YES;
        [tableView addSubview:emptyLabel];
        
        [_tableViews addObject:tableView];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _mainView.frame.size.width;
    int newPage = _mainView.contentOffset.x / pageWidth;
    float newPagef = _mainView.contentOffset.x / pageWidth;
    
    if (newPage != _tabIndex){
        if (newPage > _tabIndex || (newPage < _tabIndex && _tabIndex - newPagef >=0.5))
        {
            _tabIndex = newPage;
            [_topView moveSelectedView:newPage];
        }
    }
}


#pragma mark - UITableViewDataSourse & Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    for (int i=0; i<_tableViews.count; i++) {
        if (tableView==_tableViews[i]) {
            for (UIView *view in tableView.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    view.hidden=[_dataArray[i] count]?YES:NO;
                }
            }
            return [_dataArray[i] count];
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownPeopleCell *cell=[tableView dequeueReusableCellWithIdentifier:@"DownPeoCell"];
    
    for (int i=0; i<_sectionArr.count; i++) {
        if (tableView==_tableViews[i]) {
            cell.dataContent=_dataArray[i][indexPath.row];
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

#pragma mark - SectionHeaderCatgoryViewDelegate

-(void)indexSelected:(int)index
{
    _mainView.contentOffset=CGPointMake(self.view.bounds.size.width*index, 0);
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

@end
