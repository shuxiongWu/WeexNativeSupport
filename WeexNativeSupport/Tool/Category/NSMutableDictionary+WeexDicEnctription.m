//
//  NSMutableDictionary+CMJFDicEnctription.m
//  CMfspay
//
//  Created by 超盟 on 2017/12/14.
//  Copyright © 2017年 mrchabao. All rights reserved.
//

#import "NSMutableDictionary+WeexDicEnctription.h"
#import "WeexEncriptionHelper.h"

#define CKJFEncriptionSecurityKey @"C&h^%Me^&Fd%&ChAiN"

@implementation NSMutableDictionary (WeexDicEnctription)

//rc4加密
- (void)setEnctriptionObject:(id)value forKey:(id)key{
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSMutableString class]]) {
        value = [WeexEncriptionHelper HloveyRC4:value key:CKJFEncriptionSecurityKey];
        NSLog(@"RC4--key:%@---value:%@",key,value);
        value = [WeexEncriptionHelper encodeBase64WithString:value];
        [self setObject:value forKey:key];
    }
    else{
        NSLog(@"---添加的不是字符串---");
    }
}

//urlEncode
- (void)setEncodeObject:(id)value forKey:(id)key{
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSMutableString class]]) {
        value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"encode--key:%@---value:%@",key,value);
        [self setObject:value forKey:key];
    }
    else{
        NSLog(@"---添加的不是字符串---");
    }
}

@end
