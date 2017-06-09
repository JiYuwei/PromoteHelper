//
//  DetailViewController.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/1.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailTitleCell.h"
#import "DetailLabelCell.h"
#import "DetailTaskCell.h"
#import "DetailImageCell.h"
#import "DetailDescribeCell.h"
#import "PHDeviceHelper.h"
#import "ChangeHeaderController.h"
#import "BaseNavViewController.h"
#import "NetworkRequest.h"

@interface DetailViewController () <UITableViewDataSource,UITableViewDelegate,DetailTaskDelegate,DetailImageDelegate,OpenCameraDelegate>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic) BOOL isUploadImg;
@property(nonatomic) BOOL isOpenBtn;
@property(nonatomic) CGFloat height;

@property(nonatomic,strong)UIProgressView *progressView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"任务详情";
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.view.backgroundColor=[UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(installChanged) name:INSTALL_CHANGED object:nil];
    
    _isUploadImg=[_appContent[@"task_type"] integerValue]==3;
    _isOpenBtn=[[_appContent allKeys] containsObject:@"is_upload"];
    
    [self prepareData];
    [self createTableView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INSTALL_CHANGED object:nil];
}

- (void)installChanged
{
    [_tableView reloadData];
}

- (void)prepareData
{
    _height=[self customSizeWithText:_appContent[@"task_require"]];
}

- (void)createTableView
{
    _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStylePlain];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [_tableView registerNib:[UINib nibWithNibName:@"DetailTitleCell" bundle:nil] forCellReuseIdentifier:@"TitleCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"DetailLabelCell" bundle:nil] forCellReuseIdentifier:@"LabelCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"DetailTaskCell" bundle:nil] forCellReuseIdentifier:@"TaskCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"DetailImageCell" bundle:nil] forCellReuseIdentifier:@"ImageCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"DetailDescribeCell" bundle:nil] forCellReuseIdentifier:@"DescribeCell"];
    
    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDataSource & Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section==0) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"TitleCell"];
        ((DetailTitleCell *)cell).delegate=self;
        ((DetailTitleCell *)cell).appContent=_appContent;
    }
    else if (indexPath.section==1){
        cell=[tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
        ((DetailLabelCell *)cell).appContent=_appContent;
    }
    else if (indexPath.section==2){
        if (_isUploadImg) {
            cell=[tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
            ((DetailImageCell *)cell).appContent=_appContent;
            ((DetailImageCell *)cell).delegate=self;
            ((DetailImageCell *)cell).isOpenBtn=_isOpenBtn;
        }
        else{
            cell=[tableView dequeueReusableCellWithIdentifier:@"TaskCell"];
            ((DetailTaskCell *)cell).appContent=_appContent;
            ((DetailTaskCell *)cell).isDoing=_isDoing;
        }
    }
    else{
        cell=[tableView dequeueReusableCellWithIdentifier:@"DescribeCell"];
        ((DetailDescribeCell *)cell).appContent=_appContent;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 100;
    }
    else if (indexPath.section==1){
        return 80+_height;
    }
    else if (indexPath.section==2){
        
        if (_isUploadImg) {
            return 420;
        }
        else{
            NSInteger taskType=[_appContent[@"task_type"] integerValue];
            
            if (taskType==2 && _isDoing) {
                return 355;
            }
        }
        
        return 1;
    }
    else if (indexPath.section==3){
        NSString *text=_appContent[@"content"];
        CGSize cSize=[text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.view.bounds.size.width-26, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height=cSize.height-147.5;
        return 220+height;
    }
    
    return 44;
}

-(CGFloat)customSizeWithText:(NSString *)text
{
    CGSize cSize=[text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.view.bounds.size.width-36, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height=cSize.height-40;
    if (height<0) {
        height=0;
    }
    
    return height;
}

#pragma mark - DetailTaskDelegate

-(void)saveTaskState
{
    NSString *appId=_appContent[@"app_id"];
    NSInteger taskType=[_appContent[@"task_type"] integerValue];
    NSInteger maxDay=[_appContent[@"task_day"] integerValue];
    
    [[PHDeviceHelper sharedHelper] saveTaskDataWithID:appId andType:[NSNumber numberWithInteger:taskType] succeed:^(NSString *dateStr, NSString *signNum, NSInteger status) {
        
        if (_refreshcb && (![dateStr isEqualToString:_appContent[@"app_open_date"]] || status==1)) {
            _refreshcb();
        }
        
        if (taskType==2) {
            
            NSMutableDictionary *appContent=[NSMutableDictionary dictionaryWithDictionary:_appContent];
            [appContent setObject:dateStr forKey:@"app_open_date"];
            [appContent setObject:signNum forKey:@"sign_num"];
            if ([signNum integerValue]>=maxDay) {
                [appContent setObject:[NSNumber numberWithInt:1] forKey:@"status"];
            }
            _appContent=nil;
            _appContent=[NSDictionary dictionaryWithDictionary:appContent];
        }
        
    }];
}

#pragma mark - DetailImageDelegate

-(void)openPhotoAlbum
{
    ChangeHeaderController *changeVC=[[ChangeHeaderController alloc] init];
    changeVC.delegate=self;
    changeVC.title=@"选择图片";
    BaseNavViewController *baseNavCtrl=[[BaseNavViewController alloc] initWithRootViewController:changeVC];
    [self presentViewController:baseNavCtrl animated:YES completion:nil];
}

-(void)submitPhotoWithImage:(UIImage *)image
{
    UIImage *uploadImg=image;
    NSLog(@"%@",uploadImg);
    
    NSString *uploadImgUrl=UPLOAD_IMG_URL;
    NSDictionary *userDic=[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
    NSString *userId=userDic[@"id"];
    NSString *appId=_appContent[@"app_id"];
    NSString *type=@"2";
    NSString *taskType=_appContent[@"task_type"];
    
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     userId,@"uid",
                                     appId,@"app_id",
                                     type,@"type",
                                     taskType,@"task_type",
                                     @"qr_img",@"name",
                                     @"qr_img.jpg",@"fileName",
                                     nil];
    
    [self showProgressAlert:@"正在上传，请耐心等待..." withMessage:nil];
    [[NetworkRequest sharedNetWorkRequest] setProgressCB:^(NSNumber *number) {
        [self performSelectorOnMainThread:@selector(updateProgress:)
                               withObject:number
                            waitUntilDone:NO];
    }];
    
    [[NetworkRequest sharedNetWorkRequest] uploadImage:uploadImgUrl parameters:parameters image:uploadImg success:^(NSDictionary *json) {
        NSLog(@"%@",json);
        [self dismissProgressAlert];
        
        if ([json[ERROR_CODE] integerValue]==0) {
            NSDictionary *dataDic=json[@"data"];
            if ([dataDic[@"state"] integerValue]==1) {
                NSMutableDictionary *newContent=[NSMutableDictionary dictionaryWithDictionary:_appContent];
                [newContent setObject:@"1" forKey:@"is_upload"];
                _appContent=[NSDictionary dictionaryWithDictionary:newContent];
                [_tableView reloadData];
                
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"上传成功！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                
                if (_refreshcb) {
                    _refreshcb();
                }
            }
            else{
                [PHDeviceHelper alert:@"上传失败"];
            }
        }
        else{
            [PHDeviceHelper alert:json[ERROR_MSG]];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [self dismissProgressAlert];
        [PHDeviceHelper alert:@"上传失败"];
    }];
}

#pragma mark - OpenCameraDelegate

-(void)openCamera
{
    
}

-(void)imageSelectedSuccessful:(UIImage *)image
{
    UITableViewCell *cell=[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    if ([cell isKindOfClass:[DetailImageCell class]]) {
        DetailImageCell *detailCell=(DetailImageCell *)cell;
        detailCell.targetImage=image;
        detailCell.expImgView.image=image;
        [detailCell.uploadBtn setTitle:@"修改截图" forState:UIControlStateNormal];
    }
}



- (void)showProgressAlert:(NSString*)title withMessage:(NSString*)message
{
    UIView *backView=[[UIView alloc] initWithFrame:self.view.bounds];
    backView.backgroundColor=[UIColor darkGrayColor];
    backView.alpha=0.3;
    backView.tag=324;
    [self.view addSubview:backView];
    
    UIView* alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 100)];
    alertView.center=CGPointMake(self.view.bounds.size.width/2, (self.view.bounds.size.height-64)/2);
    alertView.backgroundColor=[UIColor blackColor];
    alertView.alpha=0.9;
    alertView.layer.cornerRadius=5;
    alertView.layer.masksToBounds=YES;
    alertView.layer.borderColor=[UIColor whiteColor].CGColor;
    alertView.layer.borderWidth=1;
    [self.view addSubview:alertView];
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 20, 240, 20)];
    label.textColor=[UIColor whiteColor];
    label.text=title;
    label.textAlignment=NSTextAlignmentCenter;
    [alertView addSubview:label];
    
    UILabel *perLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 65, 120, 20)];
    perLabel.textColor=[UIColor whiteColor];
    perLabel.textAlignment=NSTextAlignmentCenter;
    perLabel.font=[UIFont systemFontOfSize:14];
    perLabel.tag=325;
    [alertView addSubview:perLabel];
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.frame = CGRectMake(20, 55, 200, 5);
    _progressView.layer.cornerRadius=2;
    _progressView.layer.masksToBounds=YES;
    _progressView.trackTintColor=[UIColor lightGrayColor];
    [alertView addSubview:_progressView];
}

- (void)updateProgress:(NSNumber*)progress
{
    _progressView.progress = [progress floatValue];
    NSInteger per=(NSInteger)([progress floatValue]*100);
    UILabel *perLabel=(UILabel *)[self.view viewWithTag:325];
    perLabel.text=[NSString stringWithFormat:@"%ld %%",per];
}

- (void)dismissProgressAlert
{
    if (_progressView == nil) {
        return;
    }
    
    if ([_progressView.superview isKindOfClass:[UIView class]]) {
        UIView* alertView = _progressView.superview;
        [alertView removeFromSuperview];
        UIView *backView=[self.view viewWithTag:324];
        [backView removeFromSuperview];
    }
    
    _progressView = nil;
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
