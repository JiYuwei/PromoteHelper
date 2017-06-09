//
//  DownPeoViewController.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/1/27.
//  Copyright © 2016年 willing. All rights reserved.
//

#import "DownPeoViewController.h"

@interface DownPeoViewController ()

@end

@implementation DownPeoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"下线人数";
    
    self.topView.hidden=YES;
    self.mainView.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64);
}


#pragma mark - OverWriteMethod

-(void)customSectionTitle
{
    self.sectionArr=@[@""];
}

-(void)retrieveData
{
    NSString *downPeoUrl=DOWN_PEOPLE_URL;
    NSDictionary *userDict=[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
    NSString *proCode=userDict[@"promoter_code"];
    
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     proCode,PROMOTER_CODE,
                                     nil];
    [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:downPeoUrl parameters:parameters success:^(NSDictionary *json) {
        NSLog(@"%@",json);
        [[self.tableViews[self.tabIndex] header] endRefreshing];
        
        if ([json[ERROR_CODE] integerValue]==0) {
            
            self.dataArray[0]=[NSMutableArray arrayWithArray:json[@"data"][@"people_pass"]];
            self.dataArray[1]=[NSMutableArray arrayWithArray:json[@"data"][@"people_verify"]];
            
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
    
    cell.downViewType=DownViewTypePeople;
    
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
