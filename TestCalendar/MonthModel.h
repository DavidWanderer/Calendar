//
//  MonthModel.h
//  TestCalendar
//
//  Created by rich on 16/2/14.
//  Copyright © 2016年 rich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonthModel : NSObject
@property (nonatomic, copy) NSString *currentDateStr;//当前的日期字符串
@property (nonatomic, assign) int firstWeekDayOfMonth;//这个月第一天是周几
@property (nonatomic, assign) int numsOfWeeks;//这个月的周数
@property (nonatomic, assign) int numsOfDays;//这个月的天数
@property (nonatomic, assign) float monthViewHeight;//计算整个月份的view的高度
@property (nonatomic, assign) float monthViewOffSet;//计算当前月份的View的偏移量
@property (nonatomic, copy) NSString *monthName;//月份的名称
@end
