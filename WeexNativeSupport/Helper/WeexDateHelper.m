//
//  CMDateHelper.m
//  WeexDemo
//
//  Created by 超盟 on 2018/8/30.
//  Copyright © 2018年 wushuxiong. All rights reserved.
//

#import "WeexDateHelper.h"

@implementation WeexDateHelper
//将时间戳转化成字符串类型参数type是转化成什么格式的例如yyyy-MM-dd
+ (NSString *)getDateStringWithTimeIntervalString:(NSString *)string withType:(NSString *)type {
    
    if (!string || string.length != 10) {
        return @"暂无";
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[string doubleValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:type];
    NSString *dateString  = [formatter stringFromDate:date];
    return dateString;
}
@end
