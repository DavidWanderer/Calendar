//
//  ViewController.m
//  TestCalendar
//
//  Created by rich on 16/2/14.
//  Copyright © 2016年 rich. All rights reserved.
//

#import "ViewController.h"
#import "CalendarView.h"
#import "MonthModel.h"

#define kAllWidth [[UIScreen mainScreen] bounds].size.width
#define kAllHeight [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()<CalendarDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];//显示白色的背景
    
    //创建一个日历控件,显示出来
    CalendarView *calendarView = [[CalendarView alloc] initWithFrame:CGRectMake(0, 60, kAllWidth, kAllHeight - 60)];
    [self.view addSubview:calendarView];
    
    //设置其实日期
    calendarView.beginDateStr = @"20150601";
    calendarView.numOfMonths = 12;
    calendarView.delegate = self;
    calendarView.showOrder = 0;//0是停留到今天,1是显示起始的日期,2是显示结束的日期
    
    //日历初始化数据
    [calendarView initData];
    
    for (MonthModel *model in calendarView.monthsArray) {
        NSLog(@"%@有%d天,%d星期,第一天是星期%d",model.currentDateStr,model.numsOfDays,model.numsOfWeeks,model.firstWeekDayOfMonth);
    }
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark-日历的代理方法
-(void)selectDay:(NSString *)date{
    NSLog(@"当前选中的日期是:%@",date);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
