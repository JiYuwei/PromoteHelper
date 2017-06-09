//
//  AboutViewController.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/7.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property(nonatomic,strong)UIImageView *iconView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *verLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"关于";
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.view.backgroundColor=[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    
    [self createUI];
}

- (void)createUI
{
    CGSize cSize=self.view.bounds.size;
    
    _iconView=[[UIImageView alloc] initWithFrame:CGRectMake(cSize.width/2-30, cSize.height/7, 60, 60)];
    _iconView.image=[UIImage imageNamed:@"icon180"];
    _iconView.layer.cornerRadius=10;
    _iconView.layer.masksToBounds=YES;
    _iconView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _iconView.layer.borderWidth=0.5;
    [self.view addSubview:_iconView];
    
    _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(cSize.width/2-50, _iconView.frame.origin.y+_iconView.frame.size.height+20, 100, 20)];
//    _titleLabel.backgroundColor=[UIColor redColor];
    _titleLabel.textAlignment=NSTextAlignmentCenter;
    _titleLabel.text=@"推广司令";
    [self.view addSubview:_titleLabel];
    
    _verLabel=[[UILabel alloc] initWithFrame:CGRectMake(cSize.width/2-50, _titleLabel.frame.origin.y+_titleLabel.frame.size.height+10, 100, 20)];
//    _verLabel.backgroundColor=[UIColor yellowColor];
    _verLabel.textAlignment=NSTextAlignmentCenter;
    _verLabel.textColor=[UIColor lightGrayColor];
    _verLabel.font=[UIFont systemFontOfSize:14];
    NSString *verStr=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _verLabel.text=[NSString stringWithFormat:@"Ver. %@",verStr];
    [self.view addSubview:_verLabel];
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
