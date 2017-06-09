//
//  MainListView.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/11/26.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "MainListView.h"
#import "CodeViewController.h"
#import "PHDeviceHelper.h"

@implementation MainListView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        self.backgroundColor=BASE_COLOR;
        [self createUI];
    }
    
    return self;
}

-(void)createUI
{
    _userView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 5, self.frame.size.height-10, self.frame.size.height-10)];
    _userView.backgroundColor=[UIColor lightGrayColor];
    _userView.layer.cornerRadius=_userView.frame.size.width/2;
    _userView.layer.masksToBounds=YES;
    _userView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _userView.layer.borderWidth=0.5;
    _userView.userInteractionEnabled=YES;
//    _userView.image=[UIImage imageNamed:@"head"];
    [_userView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPersonalVC)]];
    
    [self addSubview:_userView];
    
    _loadingView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _loadingView.center=CGPointMake(_userView.frame.size.width/2,_userView.frame.size.height/2);
    
    [_userView addSubview:_loadingView];
    [_loadingView startAnimating];
    
    _userLabel=[[UILabel alloc] initWithFrame:CGRectMake(15+_userView.frame.size.width, 5+_userView.frame.size.height/4, 150, _userView.frame.size.height/2)];
    _userLabel.textColor=[UIColor whiteColor];
    _userLabel.font=[UIFont systemFontOfSize:14];
    _userLabel.text=@"正在登录";
//    _userLabel.backgroundColor=[UIColor yellowColor];
    [self addSubview:_userLabel];
    
    
//    _shareBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    _shareBtn.frame=CGRectMake(self.bounds.size.width-15-_userView.frame.size.width*2, 5, _userView.frame.size.width, _userView.frame.size.height);
////    _shareBtn.backgroundColor=[UIColor purpleColor];
//    [self addSubview:_shareBtn];
    
    _codeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _codeBtn.frame=CGRectMake(self.bounds.size.width-5-_userView.frame.size.width, 5, _userView.frame.size.width, _userView.frame.size.height);
    [_codeBtn setImage:[UIImage imageNamed:@"code"] forState:UIControlStateNormal];
    _codeBtn.hidden=YES;
    [_codeBtn addTarget:self action:@selector(showCodeImgVC) forControlEvents:UIControlEventTouchUpInside];
//    _codeBtn.backgroundColor=[UIColor grayColor];
    [self addSubview:_codeBtn];
}

-(void)showPersonalVC
{
    [self.delegate openPersonalPage];
}

-(void)showCodeImgVC
{
    CodeViewController *codeVC=[[CodeViewController alloc] init];
    [[[PHDeviceHelper sharedHelper] viewControllerWithView:self].navigationController pushViewController:codeVC animated:YES];
}

@end
