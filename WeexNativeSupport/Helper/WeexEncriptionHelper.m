//
//  WeexEncriptionHelper.m
//  CMfspay
//
//  Created by 超盟 on 2017/12/14.
//  Copyright © 2017年 mrchabao. All rights reserved.
//

#import "WeexEncriptionHelper.h"
#import <CommonCrypto/CommonDigest.h>
//#define CKJFEncriptionSecurityKey @"NuHjhg%&^fxF57cGnm"
static const char _bas64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _base64DecodingTable[256] = {
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

@implementation WeexEncriptionHelper
// 十六进制转换为普通字符串的。
+ (NSString *)stringFromHexString:(NSString *)hexString {  // eg. hexString = @"8c376b4c"
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:NSISOLatin1StringEncoding];
    //    printf("%s\n", myBuffer);
    free(myBuffer);
    
//    NSString *temp1 = [unicodeString stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
//    NSString *temp2 = [temp1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
//    NSString *temp3 = [[@"\"" stringByAppendingString:temp2] stringByAppendingString:@"\""];
//    NSData *tempData = [temp3 dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *temp4 = [NSPropertyListSerialization propertyListFromData:tempData
//                                                       mutabilityOption:NSPropertyListImmutable
//                                                                 format:NULL
//                                                       errorDescription:NULL];
//    NSString *string = [temp4 stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
    
    NSLog(@"-------string----%@", unicodeString); //输出 谷歌
    return unicodeString;
}

+ (NSString*)HloveyRC4:(NSString*)aInput key:(NSString*)aKey
{
    NSMutableArray *iS = [[NSMutableArray alloc] initWithCapacity:256];
    NSMutableArray *iK = [[NSMutableArray alloc] init];
    NSMutableArray *iD = @[].mutableCopy;
    
    for (int i=0; i<256; i++) {
        [iS addObject:[NSNumber numberWithInt:i]];
    }
    
    int j=0;
    for (int i=0; i<aKey.length; i++) {
        UniChar c = [aKey characterAtIndex:i%(aKey.length)];
        [iK addObject:[NSNumber numberWithChar:c]];
    }
    
    for (int i=0; i<aInput.length; i++) {
        UniChar c = [aInput characterAtIndex:i%(aInput.length)];
        [iD addObject:[NSNumber numberWithChar:c]];
    }
    
//    j=0;
    int index1 = 0,index2 = 0;
    for (int count = 0; count < 256; count++) {
        index2 = ([iK[index1] integerValue] + [iS[count] integerValue] + index2)%256;
        NSNumber *temp = iS[count];
        [iS replaceObjectAtIndex:count withObject:[iS objectAtIndex:index2]];
        [iS replaceObjectAtIndex:index2 withObject:temp];
        index1 = (index1 + 1) % iK.count;
    }
    
    int i=0;
    j=0;
    
    Byte byteBuffer[aInput.length];
    
    NSString *result = aInput;
    for (int x=0; x<[aInput length]; x++) {
        i = (i+1)%256;
        
        int is = [[iS objectAtIndex:i] intValue];
        j = (j+is)%256;
        
        int is_i = [[iS objectAtIndex:i] intValue];
        int is_j = [[iS objectAtIndex:j] intValue];
        
        //改动2:增加交换is_i和is_j的具体内容
        [iS exchangeObjectAtIndex:i withObjectAtIndex:j];
        
        int t = (is_i+is_j)%256;
        int iY = [[iS objectAtIndex:t] intValue];
        
        
        
        UniChar ch = (UniChar)[aInput characterAtIndex:x];
        UniChar ch_y = ch^iY;
        byteBuffer[x] = ch_y;
        
//        result = [result stringByReplacingCharactersInRange:NSMakeRange(x, 1) withString:[NSString stringWithCharacters:&ch_y length:1]];
    }
//    NSData *adata = [[NSData alloc] initWithBytes:byteBuffer length:aInput.length];
//    NSLog(@"adata:%@",adata);
//    result = [[NSString alloc]initWithData:adata encoding:NSISOLatin1StringEncoding];
    
    
    result = [self byteToBase64String:byteBuffer lengh:sizeof(byteBuffer)];
    return result;
}

+ (NSData *)rc4Decode:(NSString*)aInput key:(NSString*)aKey {
    NSMutableArray *iS = [[NSMutableArray alloc] initWithCapacity:256];
    NSMutableArray *iK = [[NSMutableArray alloc] init];
    NSMutableArray *iD = @[].mutableCopy;
    
    for (int i=0; i<256; i++) {
        [iS addObject:[NSNumber numberWithInt:i]];
    }
    
    int j=0;
    for (int i=0; i<aKey.length; i++) {
        UniChar c = [aKey characterAtIndex:i%(aKey.length)];
        [iK addObject:[NSNumber numberWithChar:c]];
    }
    
    for (int i=0; i<aInput.length; i++) {
        UniChar c = [aInput characterAtIndex:i%(aInput.length)];
        [iD addObject:[NSNumber numberWithChar:c]];
    }
    
    //    j=0;
    int index1 = 0,index2 = 0;
    for (int count = 0; count < 256; count++) {
        index2 = ([iK[index1] integerValue] + [iS[count] integerValue] + index2)%256;
        NSNumber *temp = iS[count];
        [iS replaceObjectAtIndex:count withObject:[iS objectAtIndex:index2]];
        [iS replaceObjectAtIndex:index2 withObject:temp];
        index1 = (index1 + 1) % iK.count;
    }
    
    int i=0;
    j=0;
    
    Byte byteBuffer[aInput.length];
    
//    NSString *result = aInput;
    for (int x=0; x<[aInput length]; x++) {
        i = (i+1)%256;
        
        int is = [[iS objectAtIndex:i] intValue];
        j = (j+is)%256;
        
        int is_i = [[iS objectAtIndex:i] intValue];
        int is_j = [[iS objectAtIndex:j] intValue];
        
        //改动2:增加交换is_i和is_j的具体内容
        [iS exchangeObjectAtIndex:i withObjectAtIndex:j];
        
        int t = (is_i+is_j)%256;
        int iY = [[iS objectAtIndex:t] intValue];
        
        
        
        UniChar ch = (UniChar)[aInput characterAtIndex:x];
        UniChar ch_y = ch^iY;
        byteBuffer[x] = ch_y;
        
//        result = [result stringByReplacingCharactersInRange:NSMakeRange(x, 1) withString:[NSString stringWithCharacters:&ch_y length:1]];
    }
    NSData *adata = [[NSData alloc] initWithBytes:byteBuffer length:aInput.length];
    return adata;
}

+ (NSString *)UnicodeToISO88591:(NSString *)src
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
    return [NSString stringWithCString:[src UTF8String] encoding:enc];
}

+ (NSString *)encodeBase64WithString:(NSString *)strData {
    return [self encodeBase64WithData:[strData dataUsingEncoding:NSUTF8StringEncoding]];
}


+ (NSString *)encodeBase64WithData:(NSData *)objData {
    const unsigned char * objRawData = [objData bytes];
    char * objPointer;
    char * strResult;
    
    NSUInteger intLength = [objData length];
    if (intLength == 0) return nil;
    
    strResult = (char *)calloc(((intLength + 2) / 3) * 4, sizeof(char));
    objPointer = strResult;
    
    while(intLength > 2) {
        *objPointer++ = _bas64EncodingTable[objRawData[0] >> 2];
        *objPointer++ = _bas64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
        *objPointer++ = _bas64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
        *objPointer++ = _bas64EncodingTable[objRawData[2] & 0x3f];
        
        objRawData += 3;
        intLength -= 3;
    }
    
    if (intLength != 0) {
        *objPointer++ = _bas64EncodingTable[objRawData[0] >> 2];
        if (intLength > 1) {
            *objPointer++ = _bas64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
            *objPointer++ = _bas64EncodingTable[(objRawData[1] & 0x0f) << 2];
            *objPointer++ = '=';
        } else {
            *objPointer++ = _bas64EncodingTable[(objRawData[0] & 0x03) << 4];
            *objPointer++ = '=';
            *objPointer++ = '=';
        }
    }
    
    *objPointer = '\0';
    
    return[NSString stringWithCString:strResult encoding:NSASCIIStringEncoding];
}


+ (NSData *)decodeBase64WithString:(NSString *)strBase64 {
    const char* objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned long intLength = strlen(objPointer);
    int intCurrent;
    int i = 0, j = 0, k;
    
    unsigned char * objResult;
    objResult = calloc(intLength, sizeof(char));
    
    while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
        if (intCurrent == '=') {
            if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
                free(objResult);
                return nil;
            }
            continue;
        }
        
        intCurrent = _base64DecodingTable[intCurrent];
        if (intCurrent == -1) {
            continue;
        } else if (intCurrent == -2) {
            free(objResult);
            return nil;
        }
        
        switch (i % 4) {
            case 0:
                objResult[j] = intCurrent << 2;
                break;
                
            case 1:
                objResult[j++] |= intCurrent >> 4;
                objResult[j] = (intCurrent & 0x0f) << 4;
                break;
                
            case 2:
                objResult[j++] |= intCurrent >>2;
                objResult[j] = (intCurrent & 0x03) << 6;
                break;
                
            case 3:
                objResult[j++] |= intCurrent;
                break;
        }
        i++;
    }
    
    k = j;
    if (intCurrent == '=') {
        switch (i % 4) {
            case 1:
                free(objResult);
                return nil;
            case 2:
                k++;
            case 3:
                objResult[k] = 0;
        }
    }
    
    NSData * objData = [[NSData alloc] initWithBytes:objResult length:j] ;
    free(objResult);
    return objData;
}

//    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:jsonString options:0];
//    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
//    NSLog(@"----%@",decodedString);

+ (NSString *)byteToBase64String:(Byte [])byteBuffer lengh:(NSInteger)buffLen
{
    NSData *adata = [[NSData alloc] initWithBytes:byteBuffer length:buffLen];
    NSString *string = [adata base64EncodedStringWithOptions:0];
    return string;
}

+ (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}

/*
 NSMutableArray *iS = [[NSMutableArray alloc] initWithCapacity:256];
 NSMutableArray *iK = [[NSMutableArray alloc] initWithCapacity:256];
 
 for (int i=0; i<256; i++) {
 [iS addObject:[NSNumber numberWithInt:i]];
 }
 
 int j=0;
 //改动1，s-box的长度应当是256，楼主之前写的是255
 for (int i=0; i<256; i++) {
 
 UniChar c = [aKey characterAtIndex:i%(aKey.length)];
 
 [iK addObject:[NSNumber numberWithChar:c]];
 }
 
 //    j=0;
 
 for (int i=0; i<256; i++) {
 int is = [[iS objectAtIndex:i] intValue];
 UniChar ik = (UniChar)[[iK objectAtIndex:i] charValue];
 
 j = (j + is + ik)%256;
 NSNumber *temp = [iS objectAtIndex:i];
 [iS replaceObjectAtIndex:i withObject:[iS objectAtIndex:j]];
 [iS replaceObjectAtIndex:j withObject:temp];
 
 }
 
 int i=0;
 j=0;
 
 Byte byteBuffer[aInput.length];
 
 NSString *result = aInput;
 for (int x=0; x<[aInput length]; x++) {
 i = (i+1)%256;
 
 int is = [[iS objectAtIndex:i] intValue];
 j = (j+is)%256;
 
 int is_i = [[iS objectAtIndex:i] intValue];
 int is_j = [[iS objectAtIndex:j] intValue];
 
 //改动2:增加交换is_i和is_j的具体内容
 [iS exchangeObjectAtIndex:i withObjectAtIndex:j];
 
 int t = (is_i+is_j)%256;
 int iY = [[iS objectAtIndex:t] intValue];
 
 
 
 UniChar ch = (UniChar)[aInput characterAtIndex:x];
 UniChar ch_y = ch^iY;
 byteBuffer[x] = ch_y;
 
 //        result = [result stringByReplacingCharactersInRange:NSMakeRange(x, 1) withString:[NSString stringWithCharacters:&ch_y length:1]];
 }
 */
@end
