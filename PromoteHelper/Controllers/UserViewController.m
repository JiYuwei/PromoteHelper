//
//  UserViewController.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/11/26.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "UserViewController.h"
#import "UserHeaderView.h"
#import "LoginViewController.h"
#import "BaseNavViewController.h"
#import "PHDeviceHelper.h"
#import "AboutViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <MJRefresh/MJRefresh.h>
#import "NetworkRequest.h"

@interface UserViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)UserHeaderView *userHeaderView;
@property(nonatomic,strong)NSDictionary *userDict;
@property(nonatomic,strong)UIActivityIndicatorView *loadingView;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"个人中心";
    self.edgesForExtendedLayout=UIRectEdgeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChaged) name:USER_CHANGED object:nil];
    
    [self prepareData];
    [self createTableView];
    [self createUserHeaderView];
    [self userChaged];
    [self refreshUserInfo];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:USER_CHANGED object:nil];
}

//更改用户
-(void)userChaged
{
    BOOL isUser=[[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULT_BOOL] || [[NSUserDefaults standardUserDefaults] boolForKey:USER_WX_BOOL];
    if (!isUser) {
        [self.navigationController popViewControllerAnimated:NO];
        
        LoginViewController *loginVC=[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        BaseNavViewController *navCtrl=[[BaseNavViewController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navCtrl  animated:YES completion:nil];
    }
    else{
        NSDictionary *userDict=[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
        _userHeaderView.userContent=userDict;
    }
}

-(void)prepareData
{
    _dataArray=[NSMutableArray arrayWithObjects:@[@"检查更新"],@[@"帮助",@"关于"], nil];
}

-(void)createTableView
{
    _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStyleGrouped];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    _tableView.header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshUserInfo];
    }];
    
    [self.view addSubview:_tableView];
}

-(void)createUserHeaderView
{
    _userHeaderView=[[UserHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [[UIScreen mainScreen] bounds].size.height/5*2)];
    _tableView.tableHeaderView=_userHeaderView;
    
    UIView *footerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
    UIButton *logOutBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    logOutBtn.frame=CGRectMake(10, 20, self.view.bounds.size.width-20, 40);
    logOutBtn.titleLabel.font=[UIFont systemFontOfSize:18];
    [logOutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logOutBtn setBackgroundColor:[UIColor colorWithRed:0.8 green:0 blue:0 alpha:1]];
    [logOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [logOutBtn addTarget:self action:@selector(logOut:) forControlEvents:UIControlEventTouchUpInside];
    logOutBtn.layer.cornerRadius=5;
    logOutBtn.layer.masksToBounds=YES;
    [footerView addSubview:logOutBtn];
    _tableView.tableFooterView=footerView;
}

-(void)logOut:(UIButton *)sender
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"注意" message:@"确定退出登录吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}


-(void)refreshUserInfo
{
    NSString *personUrl=PERSON_INFO_URL;
    NSDictionary *userDic=[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
    NSString *userId=userDic[@"id"];
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys: userId,@"id", nil];
    
    [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:personUrl parameters:parameters success:^(NSDictionary *json) {
        [_tableView.header endRefreshing];
        NSLog(@"%@",json);
        if ([json[ERROR_CODE] integerValue]==0) {
            NSDictionary *dic=json[@"data"];
            _userHeaderView.dataContent=dic;
        }
    } failure:^(NSError *error) {
        [_tableView.header endRefreshing];
        NSLog(@"%@",error);
        [PHDeviceHelper alert:@"网络不给力，请稍后再试。"];
    }];
}

#pragma UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [self logOut];
    }
}

//退出登录
-(void)logOut
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_WX_BOOL]) {
        if ([ShareSDK hasAuthorized:SSDKPlatformTypeWechat]) {
            [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_BOOL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_WX_BOOL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MOBILE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DATA];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WX_LOGIN_DATA];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGED object:nil];
}

#pragma mark - UITableViewDataSource & Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray[section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (indexPath.section!=0) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        if (!_loadingView) {
            _loadingView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _loadingView.center=CGPointMake([UIScreen mainScreen].bounds.size.width-25, cell.frame.size.height/2);
            [cell addSubview:_loadingView];
        }
    }
    
    cell.textLabel.text=_dataArray[indexPath.section][indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        [_loadingView startAnimating];
        [PHDeviceHelper checkUpdateFinished:^{
            [_loadingView stopAnimating];
        } isDirectly:NO];
    }
    else{
        switch (indexPath.row) {
            case 0:{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"帮助" message:@"需要支持请联系supprt@shwilling.com。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
            case 1:{
                AboutViewController *aboutVC=[[AboutViewController alloc] init];
                [self.navigationController pushViewController:aboutVC animated:YES];
                break;
            }
                
            default:
                break;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
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
