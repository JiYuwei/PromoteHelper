//
//  DownTaskDetailController.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/1/28.
//  Copyright © 2016年 willing. All rights reserved.
//

#import "DownTaskDetailController.h"

@interface DownTaskDetailController ()

@end

@implementation DownTaskDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)setAppName:(NSString *)appName
{
    if (_appName!=appName) {
        _appName=appName;
    }
    
    self.title=[NSString stringWithFormat:@"%@进度",_appName];
    
}


#pragma mark - OverWriteMethod

-(void)customSectionTitle
{
    self.sectionArr=@[@""];
}

-(void)createTopView
{
    [self customSectionTitle];
    self.sectionHeight=0;
}

-(void)retrieveData
{
    NSString *downTaskUrl=DOWN_TASK_DETAIL_URL;
    NSDictionary *userDict=[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
    NSString *proCode=userDict[@"promoter_code"];
    NSString *appId=_appId;
    
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     proCode,PROMOTER_CODE,
                                     appId,APP_ID,
                                     nil];
    [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:downTaskUrl parameters:parameters success:^(NSDictionary *json) {
        NSLog(@"%@",json);
        [[self.tableViews[self.tabIndex] header] endRefreshing];
        
        if ([json[ERROR_CODE] integerValue]==0) {
            
            self.dataArray[0]=[NSMutableArray arrayWithArray:json[@"data"]];
            [self.tableViews makeObjectsPerformSelector:@selector(reloadData)];
        }
        else{
            [PHDeviceHelper alert:json[ERROR_MSG]];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [[self.tableViews[self.tabIndex] header] endRefreshing];
        [PHDeviceHelper alert:@"网络不给力，请稍后再试。"];
    }];
}



#pragma mark - OverWriteDelegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownPeopleCell *cell=(DownPeopleCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.downViewType=DownViewTypeTaskDetail;
    
    return cell;
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
