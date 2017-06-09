//
//  DownViewController.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/1/26.
//  Copyright © 2016年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionHeaderCatgoryView.h"
#import <MJRefresh/MJRefresh.h>
#import "NetworkRequest.h"
#import "PHDeviceHelper.h"
#import "DownPeopleCell.h"

@interface DownViewController : UIViewController <UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,SectionHeaderCatgoryDelegate>

@property(nonatomic,strong) SectionHeaderCatgoryView *topView;
@property(nonatomic,strong) NSArray *sectionArr;
@property(nonatomic,strong) UIScrollView *mainView;
@property(nonatomic,strong) NSMutableArray *tableViews;
@property(nonatomic,strong) NSMutableArray *dataArray;
@property(nonatomic) NSInteger tabIndex;
@property(nonatomic) CGFloat sectionHeight;

-(void)customSectionTitle;
-(void)createTopView;
-(void)retrieveData;

@end
