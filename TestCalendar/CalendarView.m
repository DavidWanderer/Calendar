//
//  CalendarView.m
//  TestCalendar
//
//  Created by rich on 16/2/14.
//  Copyright © 2016年 rich. All rights reserved.
//



#import "CalendarView.h"
#import "MonthModel.h"

#define weekNameViewH 35 //星期几的高度
#define weekNameViewX 5 //星期的横坐标
#define weekNameViewW self.calendarView.frame.size.width-10 //星期几的宽度
#define weekLabelW (self.calendarView.frame.size.width-10)/7.0 //星期几的每个label的宽度
#define monthNameViewH 40 //月份的高度
#define monthDayLabelH (self.calendarView.frame.size.width-10)/7.0*1.2 //天View的高度

#define kCustomRGBColor(x,y,z,t) [[UIColor alloc] initWithRed:x/255.0 green:y/255.0 blue:z/255.0 alpha:t/1.0]

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

/**
 *  0 offset显示当天的,1 offset显示起始的日期,2 offset显示结束的日期
 */
typedef NS_ENUM(NSInteger, ShowWay) {
    Today = 0,
    Order = 1,
    ReverseOrder = 2
};

@implementation CalendarView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //初始化日历控件
        self.calendarView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        //self.calendarView.backgroundColor = [UIColor redColor];
        self.calendarView.showsVerticalScrollIndicator = NO;
        self.calendarView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.calendarView];
    }
    return self;
}

//初始化数据,并进行各种标志检查
-(void)initData{
    
    [self initMonthsArray];
    [self showMonthViews];
    [self addSubview:self.weekNameView];
    
}

#pragma mark-懒加载
- (NSCalendar *)calendar{
    if(!_calendar){
#ifdef __IPHONE_8_0
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
#else
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
#endif
        _calendar.timeZone = [NSTimeZone localTimeZone];
        _calendar.locale = [NSLocale currentLocale];
    }
    return _calendar;
}

- (NSDateFormatter *)formatter{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyyMMdd"];
    }
    return _formatter;
}

- (NSDateFormatter *)yearFormatter{
    if (!_yearFormatter) {
        _yearFormatter = [[NSDateFormatter alloc] init];
        [_yearFormatter setDateFormat:@"yyyy"];
    }
    return _yearFormatter;
}

- (NSDateFormatter *)monthFormatter{
    if (!_monthFormatter) {
        _monthFormatter = [[NSDateFormatter alloc] init];
        [_monthFormatter setDateFormat:@"MM"];
    }
    return _monthFormatter;
}

- (NSString *)tdYear{
    if (!_tdYear) {
        NSDate *date = [NSDate date];
        NSString *dateStr = [self.formatter stringFromDate:date];
        _tdYear = [dateStr substringWithRange:NSMakeRange(0, 4)];
    }
    return _tdYear;
}

- (NSString *)tdMonth{
    if (!_tdMonth) {
        NSDate *date = [NSDate date];
        NSString *dateStr = [self.formatter stringFromDate:date];
        _tdMonth = [dateStr substringWithRange:NSMakeRange(4, 2)];
    }
    return _tdMonth;
}

-(NSString *)tdDay{
    if (!_tdDay) {
        NSDate *date = [NSDate date];
        NSString *dateStr = [self.formatter stringFromDate:date];
        _tdDay = [dateStr substringWithRange:NSMakeRange(6, 2)];
    }
    return _tdDay;
}

- (NSString *)tdDate{
    if (!_tdDate) {
        _tdDate = [NSString stringWithFormat:@"%@%@%@",self.tdYear,self.tdMonth,self.tdDay];
    }
    return _tdDate;
}

#pragma mark-计算一个月有多少天
-(int)getNumOfDaysWithDate:(NSDate *)targetDate{
    NSRange days = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:targetDate];
    return (int)days.length;
}

#pragma mark-计算一个月有多少个星期
-(int)getNumOfWeeksWithDate:(NSDate *)targetDate{
    NSRange weeks = [self.calendar rangeOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:targetDate];
    return (int)weeks.length;
}

#pragma mark-计算每个月第一天是星期几
- (int)getMonthFirstWeekDay:(int)currentMonth andCurrentYear:(int)currentYear{
    NSDateComponents *tempComponents = [[NSDateComponents alloc] init];
    [tempComponents setYear:currentYear];
    [tempComponents setMonth:currentMonth];
    [tempComponents setDay:1];
    
    NSDate *tempDate = [self.calendar dateFromComponents:tempComponents];
    NSDateComponents *resultComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:tempDate];
    
    int weekDay = (int)[resultComponents weekday];
    
    return weekDay;
}

#pragma mark-获取全部月份模型的数组
-(void)initMonthsArray{
        self.monthsArray = [NSMutableArray array];
        
        //开始计算月份
        if (self.beginDateStr) {
            //从开始日期开始计算
            NSDate *beginDate = [self.formatter dateFromString:self.beginDateStr];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setYear:0];
            [components setMonth:self.numOfMonths];
            [components setDay:0];
            NSDate *endDate = [self.calendar dateByAddingComponents:components toDate:beginDate options:0];
            self.endDateStr = [self.formatter stringFromDate:endDate];
        }else{
            //从结束日期开始计算
            if (self.endDateStr) {
                NSDate *endDate = [self.formatter dateFromString:self.endDateStr];
                NSDateComponents *components = [[NSDateComponents alloc] init];
                [components setYear:0];
                [components setMonth:-self.numOfMonths];
                [components setDay:0];
                NSDate *beginDate = [self.calendar dateByAddingComponents:components toDate:endDate options:0];
                self.beginDateStr = [self.formatter stringFromDate:beginDate];
            }else{
                NSLog(@"您设置的起止时间有问题!");
            }
        }
        
        //获取起止的日期
        NSDate *beginDate = [self.formatter dateFromString:self.beginDateStr];
        //NSDate *endDate = [self.formatter dateFromString:self.endDateStr];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        float sumOffset = 0;//计算偏移量

        //循环创建月份模型
        for (int i=0; i<self.numOfMonths; i++) {
            //获得要计算的月份的日期
            [components setYear:0];
            [components setMonth:i];
            [components setDay:0];
            NSDate *targetDate = [self.calendar dateByAddingComponents:components toDate:beginDate options:0];
            //需要计算的月份的年和月
            NSString *year = [self.yearFormatter stringFromDate:targetDate];
            NSString *month = [self.monthFormatter stringFromDate:targetDate];
            
            MonthModel *model = [[MonthModel alloc] init];
            model.numsOfDays = [self getNumOfDaysWithDate:targetDate];
            model.numsOfWeeks = [self getNumOfWeeksWithDate:targetDate];
            model.firstWeekDayOfMonth = [self getMonthFirstWeekDay:[month intValue] andCurrentYear:[year intValue]];
            model.currentDateStr = [self.formatter stringFromDate:targetDate];
            //计算月份的高度
            model.monthViewHeight = monthNameViewH + monthDayLabelH*model.numsOfWeeks;
            model.monthViewOffSet = sumOffset;
            [_monthsArray addObject:model];
            sumOffset+=model.monthViewHeight;
        }
        
        self.offsetAll = sumOffset;
}

#pragma mark-创建显示星期几的视图
-(UIView *)weekNameView{
    if (!_weekNameView) {
        float viewW = weekNameViewW;
        float viewX = weekNameViewX;
        float viewH = weekNameViewH;
        _weekNameView = [[UIView alloc] initWithFrame:CGRectMake(viewX, -viewH, viewW, viewH)];
        
        //计算一个Label的宽度和位置
        float lbW = weekLabelW;
        float lbY = 0;
        float lbH = viewH;
        for (int i=0; i<7; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*lbW, lbY, lbW, lbH)];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [self getWeekNameWithNum:i];
            if (i==0||i==6) {
                label.textColor = kCustomRGBColor(134, 134, 134, 1.0);
            }else{
                label.textColor = [UIColor blackColor];
            }
            label.font = [UIFont systemFontOfSize:12.0];
            [_weekNameView addSubview:label];
        }
    }
    return _weekNameView;
}

-(NSString *)getWeekNameWithNum:(int)num{
    NSString *weekName = @"日";
    switch (num) {
        case 0:
            weekName = @"日";
            break;
        case 1:
            weekName = @"一";
            break;
        case 2:
            weekName = @"二";
            break;
        case 3:
            weekName = @"三";
            break;
        case 4:
            weekName = @"四";
            break;
        case 5:
            weekName = @"五";
            break;
        case 6:
            weekName = @"六";
            break;
        default:
            break;
    }
    return weekName;
}

#pragma mark-根据月份来显示名称
-(NSString *)getMonthName:(NSString *)month{
    NSString *monthName = @"一月";
    int monthNum = [month intValue];
    switch (monthNum) {
        case 1:
            monthName = @"一月";
            break;
        case 2:
            monthName = @"二月";
            break;
        case 3:
            monthName = @"三月";
            break;
        case 4:
            monthName = @"四月";
            break;
        case 5:
            monthName = @"五月";
            break;
        case 6:
            monthName = @"六月";
            break;
        case 7:
            monthName = @"七月";
            break;
        case 8:
            monthName = @"八月";
            break;
        case 9:
            monthName = @"九月";
            break;
        case 10:
            monthName = @"十月";
            break;
        case 11:
            monthName = @"十一月";
            break;
        case 12:
            monthName = @"十二月";
            break;
        default:
            break;
    }
    return monthName;
}

#pragma mark-显示每一个月份的View
-(void)showMonthViews{
    //设置calendarView的contentSize的大小
    self.calendarView.contentSize = CGSizeMake(weekNameViewW, self.offsetAll);
    
    for (int i=0; i<self.numOfMonths; i++) {
        //首先获月份模型
        MonthModel *model = [self.monthsArray objectAtIndex:i];
        
        //根据月份模型中的高度和偏移量就可以计算出monthView的Frame
        UIView *monthView = [[UIView alloc] initWithFrame:CGRectMake(weekNameViewX, model.monthViewOffSet, weekNameViewW, model.monthViewHeight)];
        //monthView.backgroundColor = [UIColor greenColor];
        [self.calendarView addSubview:monthView];
        
        //先画出月份名字View
        float monthNVX = (model.firstWeekDayOfMonth - 1)*weekLabelW;
        float monthNVY = 0;
        float monthNVW = weekLabelW;
        float monthNVH = monthNameViewH;
        UIView *monthNameView = [[UIView alloc] initWithFrame:CGRectMake(monthNVX, monthNVY, monthNVW, monthNVH)];
        //monthNameView.backgroundColor = [UIColor yellowColor];
        [monthView addSubview:monthNameView];
        
        UILabel *monthNamelb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, monthNVW, monthNVH)];
        monthNamelb.text = [self getMonthName:[model.currentDateStr substringWithRange:NSMakeRange(4, 2)]];
        if (([[model.currentDateStr substringWithRange:NSMakeRange(0, 4)] isEqualToString:self.tdYear])&&([[model.currentDateStr substringWithRange:NSMakeRange(4, 2)] isEqualToString:self.tdMonth])) {
            monthNamelb.textColor = [UIColor redColor];
        }else{
            monthNamelb.textColor = [UIColor blackColor];
        }
        
        if (iPhone5) {
            monthNamelb.font = [UIFont systemFontOfSize:13.0];
        }else{
            monthNamelb.font = [UIFont systemFontOfSize:14.0];
        }
        
        monthNamelb.textAlignment = NSTextAlignmentCenter;
        [monthNameView addSubview:monthNamelb];
        
        
        //再画出月份的天的内容
        //float firstDayX = monthNVX;
        float firstDayY = monthNVY + monthNVH;
        float firstDayW = weekLabelW;
        float firstDayH = monthDayLabelH;
        for (int i=0; i<model.numsOfDays; i++) {
            float currentDayY = firstDayY + (i + model.firstWeekDayOfMonth)/7*firstDayH;
            if ((i + model.firstWeekDayOfMonth)%7==0) {
                currentDayY -= firstDayH;
            }
            float currentDayX = ((i + model.firstWeekDayOfMonth)%7 - 1)*firstDayW;
            if (currentDayX<0) {
                currentDayX = 6 * firstDayW;
            }
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(currentDayX, currentDayY, firstDayW, firstDayH)];
            view.backgroundColor = [UIColor clearColor];
            if (i<=(7-model.firstWeekDayOfMonth)) {
                [self setBorderWithView:view top:YES left:NO bottom:NO right:NO borderColor:kCustomRGBColor(224, 224, 224, 1.0) borderWidth:1.0];
            }
            //设置月份View的Tag
            NSString *tagStr = [NSString stringWithFormat:@"%@%02i",[model.currentDateStr substringWithRange:NSMakeRange(0, 6)],i+1];
            view.tag = [tagStr intValue];
            //给View添加事件
            view.userInteractionEnabled = YES;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectDayView:)];
            [view addGestureRecognizer:gesture];
            [monthView addSubview:view];
            
            UILabel *dayLabel = nil;
            if (iPhone5) {
                dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, firstDayW - 10, firstDayW - 10)];
            }else{
                dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, firstDayW - 20, firstDayW - 20)];
            }
            
            
            dayLabel.text = [NSString stringWithFormat:@"%d",i+1];
            dayLabel.textAlignment = NSTextAlignmentCenter;
            dayLabel.backgroundColor = [UIColor clearColor];
//            dayLabel.layer.borderColor = [[UIColor clearColor] CGColor];
//            dayLabel.layer.borderWidth = 0;
            
//            if (iPhone5) {
//                dayLabel.font = [UIFont systemFontOfSize:12.0];
//            }else{
//                dayLabel.font = [UIFont systemFontOfSize:15.0];
//            }
            
            if ([self isWeekendWithTag:view.tag]) {
                dayLabel.textColor = kCustomRGBColor(134, 134, 134, 1.0);
            }else{
                dayLabel.textColor = [UIColor blackColor];
            }
            
            if ([[NSString stringWithFormat:@"%ld",view.tag] isEqualToString:self.tdDate]) {
                dayLabel.backgroundColor = kCustomRGBColor(230, 46, 37, 1.0);
                dayLabel.textColor = [UIColor whiteColor];
                dayLabel.layer.cornerRadius = dayLabel.frame.size.width/2.0;
                dayLabel.layer.masksToBounds = YES;
            }else{
                dayLabel.backgroundColor = [UIColor clearColor];
            }
            
            [view addSubview:dayLabel];
        }
    }
    
    //显示日历
    if (self.showOrder == Today) {
        for (MonthModel *model in self.monthsArray) {
            if ([[model.currentDateStr substringWithRange:NSMakeRange(0, 4)] isEqualToString:self.tdYear]&&[[model.currentDateStr substringWithRange:NSMakeRange(4, 2)] isEqualToString:self.tdMonth]) {
                self.calendarView.contentOffset = CGPointMake(0, model.monthViewOffSet);
            }
        }
    }else if (self.showOrder == Order){
        self.calendarView.contentOffset = CGPointMake(0, 0);
    }else{
        float offSetY = self.calendarView.contentSize.height - self.calendarView.frame.size.height;
        self.calendarView.contentOffset = CGPointMake(0, offSetY);
    }
}

#pragma mark-判断是不是周末
- (BOOL)isWeekendWithTag:(NSInteger)tag{
    NSString *dateStr = [NSString stringWithFormat:@"%ld",tag];
    NSDate *date = [self.formatter dateFromString:dateStr];

    NSDateComponents *components = [self.calendar components:NSCalendarUnitWeekday fromDate:date];
    NSInteger weekNum = components.weekday;
    if ((weekNum == 1)||(weekNum == 7)) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark-给某一边加上边框
- (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width
{
    if (top) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (left) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (bottom) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.frame.size.height - width, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (right) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(view.frame.size.width - width, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
}

#pragma mark-选中某一天的代理方法
-(void)selectDayView:(UITapGestureRecognizer *)gesture{
    [self deSelectDayView];//取消选中的DayView
    
    self.selectedDayView = (UIView *)gesture.view;
    
    if ([[NSString stringWithFormat:@"%ld",self.selectedDayView.tag] isEqualToString:self.tdDate]) {
        NSLog(@"选中了今天");
    }else{
        for (UIView *subView in self.selectedDayView.subviews) {
            if ([subView isKindOfClass:[UILabel class]]) {
                self.selectedDayLabel = (UILabel *)subView;
                self.selectedDayLabel.layer.cornerRadius = subView.frame.size.width/2.0;
                self.selectedDayLabel.backgroundColor = [UIColor blackColor];
                self.selectedDayLabel.textColor = [UIColor whiteColor];
                self.selectedDayLabel.layer.masksToBounds = YES;
            }
        }
    }
    
    
    
    //执行选中的代理方法
    if ([self.delegate respondsToSelector:@selector(selectDay:)]) {
        [self.delegate selectDay:[NSString stringWithFormat:@"%ld",self.selectedDayView.tag]];
    }
}

#pragma mark-取消选中某一天的代理方法
-(void)deSelectDayView{
    
    if (self.selectedDayView!=nil&&self.selectedDayLabel!=nil) {
        //判断取消选中的是不是今天
        if ([[NSString stringWithFormat:@"%ld",self.selectedDayView.tag] isEqualToString:self.tdDate]) {
            NSLog(@"选中了今天");
        }else{
            self.selectedDayLabel.textColor = [UIColor blackColor];
            self.selectedDayLabel.backgroundColor = [UIColor clearColor];
            self.selectedDayLabel.layer.masksToBounds = NO;
            self.selectedDayLabel.layer.cornerRadius = 0;
            
            //改变文字的颜色
            if ([self isWeekendWithTag:self.selectedDayView.tag]) {
                self.selectedDayLabel.textColor = kCustomRGBColor(134, 134, 134, 1.0);
            }else{
                self.selectedDayLabel.textColor = [UIColor blackColor];
            }
        }
    }
    
    //执行取消选中的代理方法
    if ([self.delegate respondsToSelector:@selector(deSelectDay:)]) {
        [self.delegate deSelectDay:[NSString stringWithFormat:@"%ld",self.selectedDayView.tag]];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
