//
//  DetailTaskCell.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/8.
//  Copyright © 2015年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"

@interface DetailTaskCell : UITableViewCell <JTCalendarDataSource>

@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContentView;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UIView *blueView;
@property (weak, nonatomic) IBOutlet UIView *redView;
@property (weak, nonatomic) IBOutlet UIView *activeView;
@property (weak, nonatomic) IBOutlet UILabel *dayCountLabel;

@property (weak, nonatomic) NSLayoutConstraint *calendarContentViewHeight;

@property(nonatomic,strong) JTCalendar *calendar;
@property(nonatomic,strong) NSDictionary *appContent;
@property(nonatomic) BOOL isDoing;

- (void)haveEventWithDate:(NSString *)dateStr andDayNum:(NSString *)dayNum;

@end
