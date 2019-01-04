//
//  NSString+NSSAutoresizing.h
//  NewSugarSource
//
//  Created by yunfu on 2017/7/16.
//  Copyright © 2017年 fuguoguo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (WeexNSSAutoresizing)
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

//字典转jsonstr
+ (NSString *)convertToJsonData:(NSDictionary *)dict;

//json 转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

//修改颜色
//+ (NSMutableAttributedString *)stringWithText:(NSString *)text range:(NSRange)range;

//银行卡号处理每4位空格
+ (NSString *)stringSeparatedBySpace:(NSString *)text;

//银行卡号处理 每4位空格加*处理
+ (NSString *)strReplaceByStar:(NSString *)bankNo;

// 十六进制转换为普通字符串的。
- (NSString *)stringFromHexString:(NSString *)hexString;
//普通字符串转十六进制
- (NSString *)hexStringFromString:(NSString *)string;
@end
