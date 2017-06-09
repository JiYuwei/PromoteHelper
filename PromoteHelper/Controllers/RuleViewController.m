//
//  RuleViewController.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/7.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "RuleViewController.h"

@interface RuleViewController ()

@property(nonatomic,strong)UIWebView *webView;

@end

@implementation RuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"条款";
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.view.backgroundColor=[UIColor whiteColor];
    
    _webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    [self.view addSubview:_webView];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:RULE_URL]]];
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
