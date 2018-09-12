//
//  CMDateHelper.h
//  WeexDemo
//
//  Created by 超盟 on 2018/8/30.
//  Copyright © 2018年 wushuxiong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMDateHelper : NSObject
//将日期转化成字符串类型参数type是转化成什么格式的例如yyyy-MM-dd
+ (NSString *)getDateStringWithTimeIntervalString:(NSString *)string withType:(NSString *)type;
@end
