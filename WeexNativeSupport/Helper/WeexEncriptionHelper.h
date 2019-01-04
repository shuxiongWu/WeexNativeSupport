//
//  CMJFEncriptionHelper.h
//  CMfspay
//
//  Created by 超盟 on 2017/12/14.
//  Copyright © 2017年 mrchabao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeexEncriptionHelper : NSObject

/**
 *-----------RC4加密
 *@pram aInput 需要加密字符串
 *@pram aKey 秘钥
 ****/
+ (NSString*)HloveyRC4:(NSString*)aInput key:(NSString*)aKey;

+ (NSData *)rc4Decode:(NSString*)aInput key:(NSString*)aKey;

//转ISO-8859-1格式
+ (NSString *)UnicodeToISO88591:(NSString *)src;

//Base64加密
+ (NSString *)encodeBase64WithString:(NSString *)strData;
+ (NSString *)encodeBase64WithData:(NSData *)objData;

//Based64解密
+ (NSData *)decodeBase64WithString:(NSString *)strBase64;

//md5加密
+ (NSString *)md5:(NSString *)input;
@end
