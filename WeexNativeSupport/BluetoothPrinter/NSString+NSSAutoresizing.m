//
//  NSString+NSSAutoresizing.m
//  NewSugarSource
//
//  Created by yunfu on 2017/7/16.
//  Copyright © 2017年 fuguoguo. All rights reserved.
//

#import "NSString+NSSAutoresizing.h"

@implementation NSString (NSSAutoresizing)
#pragma mark 计算字符串大小
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *dict = @{NSFontAttributeName: font};
    CGSize textSize = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return textSize;
}

//字典转jsonstr
+ (NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
//    //去掉字符串中的空格
//
//    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
//
//    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range];
    
    return mutStr;
}


//json 转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSString *)stringSeparatedBySpace:(NSString *)text{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"*0123456789\b"];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *newString = @"";
    while (text.length > 0) {
        NSString *subString = [text substringToIndex:MIN(text.length, 4)];
        newString = [newString stringByAppendingString:subString];
        if (subString.length == 4) {
            newString = [newString stringByAppendingString:@" "];
        }
        text = [text substringFromIndex:MIN(text.length, 4)];
    }
    
    newString = [newString stringByTrimmingCharactersInSet:[characterSet invertedSet]];
    
//    if ([newString stringByReplacingOccurrencesOfString:@" " withString:@""].length >= 21) {
//        return @"";
//    }
    return newString;
}

+ (NSString *)strReplaceByStar:(NSString *)bankNo{
    NSString *repalceStr;
    NSString *tempStr = @"";
    if ([bankNo isKindOfClass:[NSString class]] && bankNo.length > 8) {
        for (int i = 4; i < bankNo.length - 4; i++) {
            if (i == 4) {
                repalceStr = @"*";
            }
            else{
                repalceStr = [NSString stringWithFormat:@"%@*",repalceStr];
            }
        }
        tempStr = [bankNo stringByReplacingCharactersInRange:NSMakeRange(4, bankNo.length - 8) withString:repalceStr];
        return [self stringSeparatedBySpace:tempStr];
    }
    else{
        return @"卡号不正确";
    }
}

// 十六进制转换为普通字符串的。
- (NSString *)stringFromHexString:(NSString *)hexString { //
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}

- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSISOLatin1StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
@end
