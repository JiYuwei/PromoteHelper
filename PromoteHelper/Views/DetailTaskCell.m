//
//  DetailTaskCell.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/8.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "DetailTaskCell.h"
#import "PHDeviceHelper.h"

@implementation DetailTaskCell
{
    NSMutableDictionary *eventsByDate;
}

- (void)drawViewRect
{
    CGFloat cWidth=[[UIScreen mainScreen] bounds].size.width;
    
    _lineView.frame=CGRectMake(_lineView.frame.origin.x, _lineView.frame.origin.y, cWidth, _lineView.frame.size.height);
    _calendarMenuView.frame=CGRectMake(_calendarMenuView.frame.origin.x, _calendarMenuView.frame.origin.y, cWidth-16, _calendarMenuView.frame.size.height);
    _calendarContentView.frame=CGRectMake(_calendarContentView.frame.origin.x, _calendarContentView.frame.origin.y, cWidth-16, _calendarContentView.frame.size.height);
    
    _blueView.layer.cornerRadius=_blueView.bounds.size.width/2;
    _blueView.layer.masksToBounds=YES;
    _redView.layer.cornerRadius=_redView.bounds.size.width/2;
    _redView.layer.masksToBounds=YES;
    _activeView.layer.cornerRadius=_activeView.bounds.size.width/2;
    _activeView.layer.masksToBounds=YES;
    
    _dayCountLabel.frame=CGRectMake(_dayCountLabel.frame.origin.x+cWidth-320, _dayCountLabel.frame.origin.y, _dayCountLabel.frame.size.width, _dayCountLabel.frame.size.height);
}

- (void)haveEventWithDate:(NSString *)dateStr andDayNum:(NSString *)dayNum
{
    if (!dateStr || dateStr.length==0) {
        return;
    }
    
    if (eventsByDate) {
        eventsByDate=nil;
    }
    eventsByDate=[[NSMutableDictionary alloc] init];
    
    NSArray *dateArr=[dateStr componentsSeparatedByString:@","];
    for (NSString *dateStr in dateArr) {
        NSDate *date=[[self dateFormatter] dateFromString:dateStr];
        NSString *key=[[PHDeviceHelper dateFormatter] stringFromDate:date];
        [eventsByDate setObject:@[date] forKey:key];
    }

    _dayCountLabel.text=[NSString stringWithFormat:@"已连续活跃：%ld天",[dayNum integerValue]];
    
    [self.calendar reloadData];
}

- (void)awakeFromNib {
    
    [self drawViewRect];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveEvent) name:CAL_EVENT object:nil];
    
    self.calendar = [JTCalendar new];
    
    // All modifications on calendarAppearance have to be done before setMenuMonthsView and setContentView
    // Or you will have to call reloadAppearance
    {
        self.calendar.calendarAppearance.calendar.firstWeekday = 1; // Sunday == 1, Saturday == 7
        self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
//        self.calendar.calendarAppearance.dayDotColor=[UIColor colorWithRed:0 green:0.6 blue:0 alpha:1];
//        self.calendar.calendarAppearance.dayDotColorSelected=[UIColor colorWithRed:0 green:0.6 blue:0 alpha:1];
//        self.calendar.calendarAppearance.dayDotColorToday=[UIColor colorWithRed:0 green:0.6 blue:0 alpha:1];
        self.calendar.calendarAppearance.ratioContentMenu = 2.;
        self.calendar.calendarAppearance.focusSelectedDayChangeMode = YES;
        
        // Customize the text for each month
        self.calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
            NSCalendar *calendar = jt_calendar.calendarAppearance.calendar;
            NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
            NSInteger currentMonthIndex = comps.month;
            
            static NSDateFormatter *dateFormatter;
            if(!dateFormatter){
                dateFormatter = [NSDateFormatter new];
                dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
            }
            
            while(currentMonthIndex <= 0){
                currentMonthIndex += 12;
            }
            
            NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
            
            return [NSString stringWithFormat:@"%ld年 %@", comps.year, monthText];
        };
    }
    
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
    
//    [self createRandomEvents];
//    [self.calendar reloadData];
}

//-(void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:CAL_EVENT object:nil];
//}

-(void)setAppContent:(NSDictionary *)appContent
{
    if (_appContent!=appContent) {
        _appContent=appContent;
    }
    
    [self haveEventWithDate:_appContent[@"app_open_date"] andDayNum:_appContent[@"sign_num"]];
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    NSString *key = [[PHDeviceHelper dateFormatter] stringFromDate:date];
    
    if(eventsByDate[key] && [eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
    NSString *key = [[PHDeviceHelper dateFormatter] stringFromDate:date];
    NSArray *events = eventsByDate[key];
    
    NSLog(@"Date: %@ - %ld events", date, [events count]);
}

- (void)calendarDidLoadPreviousPage
{
    NSLog(@"Previous page loaded");
}

- (void)calendarDidLoadNextPage
{
    NSLog(@"Next page loaded");
}

#pragma mark - Transition examples

- (void)transitionExample
{
    CGFloat newHeight = 270;
    if(self.calendar.calendarAppearance.isWeekMode){
        newHeight = 75.;
    }
    
    [UIView animateWithDuration:.5
                     animations:^{
                         self.calendarContentViewHeight.constant = newHeight;
                         [self layoutIfNeeded];
                     }];
    
    [UIView animateWithDuration:.25
                     animations:^{
                         self.calendarContentView.layer.opacity = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.calendar reloadAppearance];
                         
                         [UIView animateWithDuration:.25
                                          animations:^{
                                              self.calendarContentView.layer.opacity = 1;
                                          }];
                     }];
}


//- (void)createRandomEvents
//{
//    eventsByDate = [NSMutableDictionary new];
//    
//    for(int i = 0; i < 30; ++i){
//        // Generate 30 random dates between now and 60 days later
//        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
//        
//        // Use the date as key for eventsByDate
//        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
//        
//        if(!eventsByDate[key]){
//            eventsByDate[key] = [NSMutableArray new];
//        }
//        
//        [eventsByDate[key] addObject:randomDate];
//    }
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSDateFormatter *)dateFormatter
{
    NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    return dateFormatter;
}

@end
