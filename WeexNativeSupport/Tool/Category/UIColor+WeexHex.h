//
//  UIColor+Hex.h
//  DValley
//
//  Created by mac_111 on 15/9/16.
//  Copyright (c) 2015年 mac - liu. All rights reserved.
//


#import <UIKit/UIKit.h>


//  16进制颜色转换

@interface UIColor (WeexHex)

+ (UIColor *)colorWithHex:(long)hexColor;

+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;

+ (UIColor *)colorwithHExString:(NSString*)color alpha:(float)opacity;
// 默认alpha位1
+ (UIColor *)colorWithHexString:(NSString *)hexString;

// 从十六进制字符串获取颜色，
// color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end
