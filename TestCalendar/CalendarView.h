//
//  CalendarView.h
//  TestCalendar
//
//  Created by rich on 16/2/14.
//  Copyright © 2016年 rich. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalendarDelegate <NSObject>

@optional
-(void)selectDay:(NSString *)date;//选中某一天时触发
-(void)deSelectDay:(NSString *)date;//取消选中某一天时触发

@end

@interface CalendarView : UIView
//开始时间
@property (nonatomic,copy) NSString *beginDateStr;
//结束时间
@property (nonatomic, copy) NSString *endDateStr;
//显示几个月份
@property (nonatomic, assign) int numOfMonths;
//总的ScrollerView
@property (nonatomic, strong) UIScrollView *calendarView;


@property (nonatomic, strong) NSCalendar *calendar;//NSCalendar的实例对象
@property (nonatomic, strong) NSDateFormatter *formatter;//NSFormatter的实例对象
@property (nonatomic, strong) NSDateFormatter *yearFormatter;//获取年份的格式
@property (nonatomic, strong) NSDateFormatter *monthFormatter;//获取月份的格式
@property (nonatomic, copy) NSString *tdYear;//今天的年份
@property (nonatomic, copy) NSString *tdMonth;//今天的月份
@property (nonatomic, copy) NSString *tdDay;//今天的号数
@property (nonatomic, copy) NSString *tdDate;//今天的日期
@property (nonatomic, strong) NSMutableArray *monthsArray;//存储所有的月份信息
@property (nonatomic, strong) UIView *weekNameView;//显示星期
@property (nonatomic, assign) float offsetAll;//所有的偏移量之和
@property (nonatomic, strong) UIView *selectedDayView;//选中的DayView
@property (nonatomic, strong) UILabel *selectedDayLabel;//选中的DayLabel
@property (nonatomic, assign) id<CalendarDelegate> delegate;//代理对象
@property (nonatomic, assign) int showOrder;//显示日历的顺序

-(void)initData;
-(void)initMonthsArray;
-(void)showMonthViews;
@end
