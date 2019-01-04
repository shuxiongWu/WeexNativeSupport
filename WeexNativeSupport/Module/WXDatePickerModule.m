//
//  WXDatePickerModule.m
//  WeexDemo
//
//  Created by 超盟 on 2018/10/30.
//  Copyright © 2018年 wusx. All rights reserved.
//

#import "WXDatePickerModule.h"
#import <WeexSDK/WXModuleProtocol.h>
#import <WeexSDK/WXExceptionUtils.h>
#import <WeexSDK/WeexSDK.h>
#import <WeexSDK/WXUtility.h>
#import "WeexDatePickerView.h"
@interface WXDatePickerModule ()<WeexdatePickerDelegate>
@property (nonatomic, strong) WeexDatePickerView *datePicker;
@property (nonatomic, copy) WXKeepAliveCallback selectDateSuccessCallBack;
@end

@implementation WXDatePickerModule

//选择日期
WX_EXPORT_METHOD(@selector(selectDateCallBack:))


+ (void)load{
    [WXSDKEngine registerModule:@"datePickerModule" withClass:[WXDatePickerModule class]];
}
                 
- (void)selectDateCallBack:(WXKeepAliveCallback)callBack{
    self.selectDateSuccessCallBack = callBack;
    _datePicker = [[WeexDatePickerView alloc] initDatePickerViewDelegate:self];
    [_datePicker showDatePickerView];
}

-(void)datePickerViewButtonIndex:(NSInteger)index withDatePicker:(UIDatePicker *)datePicker{
    if (index==2){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateFormat = @"yyyy-MM-dd";
        self.selectDateSuccessCallBack([self transTotimeSp:[formatter stringFromDate:datePicker.date]], YES);
    }
}

- (NSString *)transTotimeSp:(NSString *)time{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]]; //设置本地时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:time];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];//时间戳
    return timeSp;
}

@end
