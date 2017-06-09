//
//  ViewController.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/11/23.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "HomeViewController.h"
#import "PHDeviceHelper.h"
#import "NetworkRequest.h"
#import "MainViewCell.h"
#import "MainListView.h"
#import "UserViewController.h"
#import "LoginViewController.h"
#import "BaseNavViewController.h"
#import "DetailViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "LSApplicationWorkspace.h"
#import "SectionHeaderCatgoryView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HomeViewController () <UITableViewDataSource,UITableViewDelegate,ShowPersonalityDelegate,SectionHeaderCatgoryDelegate,MainViewDelegate>

@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)NSArray *sectionArr;
@property(nonatomic,strong)NSMutableArray *tableViews;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)MainListView *topView;
@property(nonatomic,strong)SectionHeaderCatgoryView *sectionView;
@property(nonatomic) NSInteger tabIndex;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"推广司令";
    self.view.backgroundColor=[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
//    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showDeviceInfo)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChanged) name:USER_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(installChanged) name:INSTALL_CHANGED object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retrieveData) name:CAL_EVENT object:nil];
    
//    NSLog(@"%@",[[PHDeviceHelper sharedHelper] getAppsInfo]);
//    NSLog(@"%@",[[PHDeviceHelper sharedHelper] getDeviceInfo]);
    
    [self createTopView];
    [self createSectionView];
    [self prepareData];
    [self createTableViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_sectionView moveSelectedView:(int)_tabIndex];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:USER_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INSTALL_CHANGED object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:CAL_EVENT object:nil];
}

//更改用户
-(void)userChanged
{
    [_topView.loadingView stopAnimating];
    BOOL isUser=[[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULT_BOOL] || [[NSUserDefaults standardUserDefaults] boolForKey:USER_WX_BOOL];
    if (!isUser) {
        _topView.userLabel.text=@"未登录";
        LoginViewController *loginVC=[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        BaseNavViewController *navCtrl=[[BaseNavViewController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navCtrl  animated:YES completion:nil];
    }
    else{
        NSDictionary *userDict=[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
        BOOL isPromoter=[userDict[@"verify_state"] integerValue];
        _topView.userLabel.text=[NSString stringWithFormat:@" %@ %@",userDict[@"nickname"],[userDict[@"verify_state"] integerValue]?@"":@"(审核中)"];
        _topView.codeBtn.hidden=isPromoter?NO:YES;
        
        if (userDict[@"headimgurl"] && [userDict[@"headimgurl"] length]!=0) {
            [_topView.userView sd_setImageWithURL:userDict[@"headimgurl"] placeholderImage:[UIImage imageNamed:@"head"]];
        }
        else{
            _topView.userView.image=[UIImage imageNamed:@"head"];
        }
        
        
        for (int i=0; i<_sectionArr.count; i++) {
            [[_tableViews[i] header] beginRefreshing];
        }
    }
}

-(void)installChanged
{
    [_tableViews makeObjectsPerformSelector:@selector(reloadData)];
}

//-(void)showDeviceInfo
//{
//    NSString *devInfo=[NSString stringWithFormat:@"%@",[[PHDeviceHelper sharedHelper] getDeviceInfo]];
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"设备信息" message:devInfo delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
//}

-(void)retrieveDataAtIndex:(NSInteger)index
{
    if (_dataArray[index]) {
        [_dataArray[index] removeAllObjects];
    }
    
    NSArray *urlList=@[APPLIST_URL,GOING_TASK_URL,FINISH_TASK_URL];
    
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2],@"type", nil];
    
    if (index!=0) {
        NSDictionary *userDic=[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
        NSString *uid=userDic[@"id"];
        [parameters setObject:uid forKey:@"uid"];
    }
    
    [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:urlList[index] parameters:parameters success:^(NSDictionary *json) {
        NSLog(@"%@",json);
        if ([json[ERROR_CODE] integerValue]==0) {
            if ([json[@"data"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary *dic in json[@"data"]) {
                    [_dataArray[index] addObject:dic];
                }
            }
            
            [_tableViews[index] reloadData];
        }
        [[_tableViews[index] header] endRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [PHDeviceHelper alert:@"刷新失败，请检查网络！"];
        [[_tableViews[index] header] endRefreshing];
    }];
}

-(void)createSectionView
{
    _sectionView=[[SectionHeaderCatgoryView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 40)];
    _sectionView.delegate=self;
    [self.view addSubview:_sectionView];
    
    _sectionArr=@[@"全部",@"进行中",@"已完成"];
    [_sectionView setSectionHeaderCategories:_sectionArr];
}

-(void)prepareData
{
    if (_dataArray) {
        _dataArray=nil;
    }
    
    _dataArray=[[NSMutableArray alloc] init];
    
    for (int i=0; i<_sectionArr.count; i++) {
        [_dataArray addObject:[[NSMutableArray alloc] init]];
    }
}

-(void)createTableViews
{
    _scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 90, self.view.bounds.size.width, self.view.bounds.size.height-64-90)];
    _scrollView.contentSize=CGSizeMake(self.view.bounds.size.width*_sectionArr.count, self.view.bounds.size.height-64-90);
    _scrollView.pagingEnabled=YES;
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.delegate=self;
    [self.view addSubview:_scrollView];
    
    _tableViews=[[NSMutableArray alloc] init];
    
    for (int i=0; i<_sectionArr.count; i++) {
        UITableView *tableView=[[UITableView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width*i, 0, _scrollView.frame.size.width, _scrollView.frame.size.height) style:UITableViewStyleGrouped];
        tableView.backgroundColor=[UIColor clearColor];
        tableView.dataSource=self;
        tableView.delegate=self;
        tableView.header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self retrieveDataAtIndex:i];
        }];
        [tableView registerNib:[UINib nibWithNibName:@"MainViewCell" bundle:nil] forCellReuseIdentifier:@"MainCell"];
        [_scrollView addSubview:tableView];
        
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

-(void)createTopView
{
    _topView=[[MainListView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    _topView.delegate=self;
//    _topView.backgroundColor=[UIColor redColor];
    [self.view addSubview:_topView];
}

#pragma mark - SectionHeaderCatgoryViewDelegate

-(void)indexSelected:(int)index
{
    _scrollView.contentOffset=CGPointMake(_scrollView.frame.size.width*index, 0);
}

#pragma mark ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _scrollView.frame.size.width;
    int newPage = _scrollView.contentOffset.x / pageWidth;
    float newPagef = _scrollView.contentOffset.x / pageWidth;
    
    if (newPage != _tabIndex){
        if (newPage > _tabIndex || (newPage < _tabIndex && _tabIndex - newPagef >=0.5))
        {
            _tabIndex = newPage;
            [_sectionView moveSelectedView:newPage];
        }
    }
}

#pragma mark - ShowPersonalityDelegate

-(void)openPersonalPage
{
    UserViewController *userVC=[[UserViewController alloc] init];
    [self.navigationController pushViewController:userVC animated:YES];
}


#pragma mark - UITableViewDataSource & Delegate

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
    MainViewCell *cell=nil;
    
    for (int i=0; i<_tableViews.count; i++) {
        if (tableView==_tableViews[i]) {
            cell=[tableView dequeueReusableCellWithIdentifier:@"MainCell"];
            
            if ([_dataArray[i] count]!=0) {
                cell.appContent=_dataArray[i][indexPath.row];
            }
            
            cell.delegate=self;
        }
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView==_tableViews[2]) {
        return;
    }
    
    DetailViewController *detailVC=[[DetailViewController alloc] init];
    detailVC.appContent=_dataArray[_tabIndex][indexPath.row];
    detailVC.isDoing=tableView==_tableViews[1];
    [detailVC setRefreshcb:^{
        for (int i=0; i<_sectionArr.count; i++) {
            [self retrieveDataAtIndex:i];
        }
    }];
    [self.navigationController pushViewController:detailVC animated:YES];
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

#pragma mark - MainViewDelegate

-(void)saveTaskStateWithID:(NSString *)appid andType:(NSNumber *)type andDateStr:(NSString *)oldDate
{
    [[PHDeviceHelper sharedHelper] saveTaskDataWithID:appid andType:type succeed:^(NSString *dateStr, NSString *signNum, NSInteger status) {
        if (![dateStr isEqualToString:oldDate] || status==1) {
            for (int i=0; i<_sectionArr.count; i++) {
                [self retrieveDataAtIndex:i];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
