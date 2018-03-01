//
//  TimeTools.m
//  testJson
//
//  Created by gorson on 3/10/15.
//  Copyright (c) 2015 gorson. All rights reserved.
//

#import "TimeTools.h"

static NSString* const appStartTime = @"2017-08-01";  //历史界面的 开始时间 (日 和 周)
static NSInteger const appStartYear = 2017;           //历史界面的 开始年份 (月)
static NSInteger const appStartMonth = 8;             //历史界面的 开始月份 (月)

#define kStart_Year appStartYear
#define kStart_Date appStartTime

@implementation TimeTools

#pragma mark - ================ 当前时间 ==================
+ (uint64_t)getCurrentTimestamp{
    //获取系统当前的时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    return a;
}

/**  获取当前标准时间（例子：2015-02-03） */
+ (NSString *)getCurrentStandarTime{
    NSDate*  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString*  locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}

/**  获取当前时间，格式自定义 ：yyyy-MM-dd HH:mm:ss（完整） */
+ (NSString*)getCurrentTimesType:(NSString*)type{
    NSDate*  senddate=[NSDate date];
    NSDateFormatter* dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:type];
    NSString*  locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}

/**  获取当天凌晨零点 的时间戳 */
+(double)getCurrentDayStartTimestamp{
    NSString* currentStr = [self getCurrentTimesType:@"yyyy-MM-dd"];
    double currentTimestamp = [self getTimestampFromTime:currentStr dateType:@"yyyy-MM-dd"];
    return currentTimestamp;
}

#pragma mark - ================ 互换 ==================
/**  时间戳转换为时间的方法 -> yyyy-MM-dd HH:mm:ss*/
+ (NSString *)timestampChangesToStandarTime:(uint64_t)timestamp{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}

/**  时间戳 -> 自定义格式的时间：yyyy-MM-dd HH:mm:ss（完整） */
+ (NSString*)timestamp:(uint64_t)timestamp changeToTimeType:(NSString*)type{
    if (timestamp<1){
        return @"";
    }
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:type];
    if (timestamp < 1000000000) {
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    }
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}

/**  时间戳 -> 星期 （日 一 二...六） */
+(NSString *)timeToweek:(uint64_t)time{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"EEEE"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:time];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}

/**  数字转 时间样式 3600 -> HH:mm:ss（完整）*/
+(NSString *)timestampChangeTimeStyle:(double)timestamp{
    if (timestamp < 0){
        return @"";
    }
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if (timestamp>=3600) {
        [formatter setDateFormat:@"HH:mm:ss"];
    }else{
        [formatter setDateFormat:@"mm:ss"];
    }
    
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}

/**  yyyy-MM-dd HH:mm:ss（完整） -> 时间戳 */
+(double)getTimestampFromTime:(NSString*)time dateType:(NSString*)dateType{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateType];
    
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    
    //------------将字符串按formatter转成nsdate
    NSDate* date = [formatter dateFromString:time];
    
    double timestamp = [date timeIntervalSince1970];
    return timestamp;
}


#pragma mark - ================ 获取月份，周 ==================
/**  获取距离2017年 的所有月份 */
+(NSArray*)getAllMonths{
    NSMutableArray* monthsArray = [NSMutableArray array];
    NSMutableArray* monthsTimestamp = [NSMutableArray array];
    
    //double startTimestamp = [self getTimestampFromTime:@"2017-01-01" dateType:@"yyyy-MM-dd"];
    double currentTimestamp = [self getCurrentTimestamp];
    
    BOOL isEnd = NO;
    NSInteger year = kStart_Year;
    while (!isEnd) {
        NSInteger i = (year == kStart_Year) ? appStartMonth : 1;
        for ( ; i<13; i++) {
            NSString* monthStr = [NSString stringWithFormat:@"%ld-%ld-01", year, i];
            double monthTimestamp = [self getTimestampFromTime:monthStr dateType:@"yyyy-MM-dd"];
            if (monthTimestamp >= currentTimestamp) {
                isEnd = YES;
                break;
            }else{
                [monthsArray addObject:[@(i) stringValue]];
                [monthsTimestamp addObject:@(monthTimestamp)];
            }
        }
        year ++;
    }
    [monthsTimestamp addObject:@(currentTimestamp)];
    
    //逆向 降序 ->  从当前时间 排到2017/01/01
    //    [monthsArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    //        return NSOrderedDescending;
    //    }];
    //    [monthsTimestamp sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    //        return NSOrderedDescending;
    //    }];
    
    [monthsArray addObject:monthsTimestamp];
    
    return monthsArray;
}

/**  获取距离2017年 的所有周 */
+(NSArray*)getAllWeeks{
    NSMutableArray* weeksArray = [NSMutableArray array];
    NSMutableArray* weeksTimestamp = [NSMutableArray array];
    long oneWeekSecond = 60*60*24*7;
    long oneDaySecond = 60*60*24;
    double startTimestamp = [self getTimestampFromTime:kStart_Date dateType:@"yyyy-MM-dd"];
    double currentTimestamp = [self getCurrentTimestamp];
    
    
    NSCalendar* calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    
    //1~7  日 一 二 三 四 五 六
    NSInteger currentWeekNum = [calendar component:NSCalendarUnitWeekday fromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    //currentWeekNum = currentWeekNum == 1 ? 7 : (currentWeekNum-1);
    
    //第一逆推的周日 时间戳
    double firstWeekTimestamp = currentTimestamp - oneDaySecond*(currentWeekNum-1);
    NSString* firstWeekStr = [self timestamp:firstWeekTimestamp changeToTimeType:@"yyyy-MM-dd"];
    firstWeekTimestamp = [self getTimestampFromTime:firstWeekStr dateType:@"yyyy-MM-dd"];
    
    //保存第一个时间戳  （当前时间戳）
    [weeksTimestamp addObject:@(currentTimestamp)];
    
    //开始 本周的结束 月/日
    NSString* weekEndStr = [self timestamp:currentTimestamp changeToTimeType:@"MM/dd"];
    
    while (1) {
        if (firstWeekTimestamp < startTimestamp) {
            break;
        }else{
            [weeksTimestamp addObject:@(firstWeekTimestamp)];
            
            NSString* weekStartStr = [self timestamp:firstWeekTimestamp changeToTimeType:@"MM/dd"];
            
            [weeksArray addObject:[NSString stringWithFormat:@"%@\n%@", weekStartStr, weekEndStr]];
            
            weekEndStr = [self timestamp:(firstWeekTimestamp - oneDaySecond) changeToTimeType:@"MM/dd"];
        }
        
        firstWeekTimestamp -= oneWeekSecond;
    }
    
    //逆序：
    [weeksTimestamp sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedDescending;
    }];
    [weeksArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedDescending;
    }];
    
    [weeksArray addObject:weeksTimestamp];
    
    return weeksArray;
}

/**  获取距离2017年 的所有日期 1~31 */
+(NSArray*)getAllDays{
    
    NSMutableArray* daysArray = [NSMutableArray array];
    NSMutableArray* daysTimestampArray = [NSMutableArray array];
    
    long oneDaySecond = 60*60*24;
    double startTimestamp = [self getTimestampFromTime:kStart_Date dateType:@"yyyy-MM-dd"];
    double currentTimestamp = [self getCurrentTimestamp];
    
    NSString* curretnDayStr = [self timestamp:currentTimestamp changeToTimeType:@"yyyy-MM-dd"];
    double currentDayTimestamp = [self getTimestampFromTime:curretnDayStr dateType:@"yyyy-MM-dd"];
    curretnDayStr = [self timestamp:currentDayTimestamp changeToTimeType:@"MM\ndd"];
    
    //添加 今天00：00 的 月日，及 时间戳
    [daysArray addObject:curretnDayStr];
    [daysTimestampArray addObject:@(currentDayTimestamp)];
    
    while (1) {
        currentDayTimestamp -= oneDaySecond;
        if (currentDayTimestamp < startTimestamp) {
            break;
        }else{
            curretnDayStr = [self timestamp:currentDayTimestamp changeToTimeType:@"MM\ndd"];
            [daysArray addObject:curretnDayStr];
            [daysTimestampArray addObject:@(currentDayTimestamp)];
        }
    }
    
    //逆序：
    [daysTimestampArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedDescending;
    }];
    [daysArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedDescending;
    }];
    
    [daysArray addObject:daysTimestampArray];
    
    return daysArray;
}


@end
