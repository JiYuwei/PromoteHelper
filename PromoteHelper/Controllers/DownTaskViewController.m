//
//  DownTaskViewController.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/1/27.
//  Copyright © 2016年 willing. All rights reserved.
//

#import "DownTaskViewController.h"
#import "DownTaskDetailController.h"

@interface DownTaskViewController ()

@end

@implementation DownTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"任务进度";
}


#pragma mark - OverWriteMethod

-(void)customSectionTitle
{
    self.sectionArr=@[@"进行中",@"已结束"];
}

-(void)retrieveData
{
    NSString *downTaskUrl=DOWN_TASK_URL;
    NSDictionary *userDict=[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
    NSString *proCode=userDict[@"promoter_code"];
    
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     proCode,PROMOTER_CODE,
                                     nil];
    [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:downTaskUrl parameters:parameters success:^(NSDictionary *json) {
        NSLog(@"%@",json);
        [[self.tableViews[self.tabIndex] header] endRefreshing];
        
        if ([json[ERROR_CODE] integerValue]==0) {
            
            self.dataArray[0]=[NSMutableArray arrayWithArray:json[@"data"][@"cooperation_app"]];
            self.dataArray[1]=[NSMutableArray arrayWithArray:json[@"data"][@"end_cooperation_app"]];
            
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
    
    cell.downViewType=DownViewTypeTask;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    for (int i=0; i<self.sectionArr.count; i++) {
        if (tableView==self.tableViews[i]) {
            NSString *appId=self.dataArray[i][indexPath.row][@"app_id"];
            NSString *appName=self.dataArray[i][indexPath.row][@"app_name"];
            DownTaskDetailController *downTaskDetailVC=[[DownTaskDetailController alloc] init];
            downTaskDetailVC.appId=appId;
            downTaskDetailVC.appName=appName;
            [self.navigationController pushViewController:downTaskDetailVC animated:YES];
            
            return;
        }
    }
    
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
