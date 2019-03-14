//
//  CMNetWorkModule.m
//  WeexDemo
//
//  Created by 超盟 on 2018/11/1.
//  Copyright © 2018年 wusx. All rights reserved.
//

#import "CMNetWorkModule.h"
#import <WeexSDK/WXExceptionUtils.h>
#import <WeexSDK/WeexSDK.h>
#import <WeexSDK/WXUtility.h>

#if __has_include(<WYNetworkManage.h>)
#import <WYNetworkManage.h>
#elif __has_include("WYNetworkManage.h")
#import "WYNetworkManage.h"
#endif

@implementation CMNetWorkModule


WX_EXPORT_METHOD(@selector(realNetworkStatus:))
WX_EXPORT_METHOD(@selector(isNetWork:))
WX_EXPORT_METHOD(@selector(isWWANNetwork:))
WX_EXPORT_METHOD(@selector(isWiFiNetwork:))
WX_EXPORT_METHOD(@selector(cancelAllRequest))
WX_EXPORT_METHOD(@selector(cancelRequestWithURL:))
WX_EXPORT_METHOD(@selector(openLog:))
WX_EXPORT_METHOD(@selector(fetch:cache:success:failure:))
WX_EXPORT_METHOD(@selector(setRequestSerializer:))
WX_EXPORT_METHOD(@selector(setResponseSerializer:))
WX_EXPORT_METHOD(@selector(setRequestTimeoutInterval:))
WX_EXPORT_METHOD(@selector(setValueForHTTPHeaderField:))
WX_EXPORT_METHOD(@selector(openNetworkActivityIndicator:))
+(void)load{
    [WXSDKEngine registerModule:@"networkModule" withClass:[CMNetWorkModule class]];
}

#pragma mark ------------------获取网络状态---------------------

/**
 实时监听网络状态
 
 @param callBack 动态返回当前网络状态
 */
- (void)realNetworkStatus:(WXKeepAliveCallback)callBack {
#if __has_include(<WYNetworkManage.h>) || __has_include("WYNetworkManage.h")
    __block NSString *netWorkStatus;
    [WYNetworkManage networkStatusWithBlock:^(WYNetworkStatusType status) {
        switch (status) {
            case WYNetworkStatusUnknown:
                netWorkStatus = @"unknown";
                break;
            case WYNetworkStatusNotReachable:
                netWorkStatus = @"notReachable";
                break;
            case WYNetworkStatusReachableViaWWAN:
                netWorkStatus = @"WAN";
                break;
            case WYNetworkStatusReachableViaWiFi:
                netWorkStatus = @"WiFi";
                break;
            default:
                break;
        }
        if (callBack) {
            callBack(netWorkStatus,YES);
        }
    }];
#else
    NSAssert(NO, @"请导入WYNetworkManager后再使用此功能");
#endif
}


/**
 当前是否有网络
 
 @param callBack YES or NO
 */
- (void)isNetWork:(WXKeepAliveCallback)callBack {
#if __has_include(<WYNetworkManage.h>) || __has_include("WYNetworkManage.h")
    BOOL bol = [WYNetworkManage isNetwork];
    if (callBack) {
        callBack(@(bol),YES);
    }
#else
    NSAssert(NO, @"请导入WYNetworkManager后再使用此功能");
#endif
}

/**
 当前是否是蜂窝网络
 
 @param callBack YES or NO
 */
- (void)isWWANNetwork:(WXKeepAliveCallback)callBack {
#if __has_include(<WYNetworkManage.h>) || __has_include("WYNetworkManage.h")
    BOOL bol = [WYNetworkManage isWWANNetwork];
    if (callBack) {
        callBack(@(bol),YES);
    }
#else
    NSAssert(NO, @"请导入WYNetworkManager后再使用此功能");
#endif
}

/**
 当前是否是WiFi网络
 
 @param callBack YES or NO
 */
- (void)isWiFiNetwork:(WXKeepAliveCallback)callBack {
#if __has_include(<WYNetworkManage.h>) || __has_include("WYNetworkManage.h")
    BOOL bol = [WYNetworkManage isWiFiNetwork];
    if (callBack) {
        callBack(@(bol),YES);
    }
#else
    NSAssert(NO, @"请导入WYNetworkManager后再使用此功能");
#endif
}

#pragma mark ------------------取消网络请求---------------------

/**
 取消所有HTTP请求
 */
- (void)cancelAllRequest {
#if __has_include(<WYNetworkManage.h>) || __has_include("WYNetworkManage.h")
    [WYNetworkManage cancelAllRequest];
#else
    NSAssert(NO, @"请导入WYNetworkManager后再使用此功能");
#endif
}


/**
 取消指定URL的HTTP请求
 
 @param URL 要取消的URL
 */
- (void)cancelRequestWithURL:(NSString *)URL {
#if __has_include(<WYNetworkManage.h>) || __has_include("WYNetworkManage.h")
    [WYNetworkManage cancelRequestWithURL:URL];
#else
    NSAssert(NO, @"请导入WYNetworkManager后再使用此功能");
#endif
}

#pragma mark ------------------日志控制---------------------


/**
 日志打印（默认关闭）
 */
- (void)openLog:(NSString *)open{
#if __has_include(<WYNetworkManage.h>) || __has_include("WYNetworkManage.h")
    if ([open boolValue]) {
        [WYNetworkManage openLog];
    }else {
        [WYNetworkManage closeLog];
    }
#else
    NSAssert(NO, @"请导入WYNetworkManager后再使用此功能");
#endif
}

#pragma mark ------------------HTTP请求---------------------

- (void)fetch:(NSDictionary *)params cache:(WXKeepAliveCallback)cache success:(WXKeepAliveCallback)success failure:(WXKeepAliveCallback)failure {
#if __has_include(<WYNetworkManage.h>) || __has_include("WYNetworkManage.h")
    NSString *method = params[@"method"] ? params[@"method"] : nil;
    NSString *url = params[@"url"] ? params[@"url"] : nil;
    BOOL bol = params[@"cache"] ? [params[@"cache"] boolValue] : NO;
    id parameters = params[@"parameters"] ? params[@"parameters"] : @{};
    
    if (parameters && ![parameters isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    if (!method || !url) return;
    
    if ([method isEqualToString:@"GET"]) {
        if (bol) {//带缓存
            [WYNetworkManage GET:url parameters:parameters responseCache:^(id  _Nonnull responseCache) {
                if ([responseCache isKindOfClass:[NSDictionary class]]) {
                    if (cache) {
                        cache([self jsonToString:responseCache],YES);
                    }
                } else if([responseCache isKindOfClass:[NSData class]]) {
                    if (cache) {
                        cache([[NSString alloc] initWithData:responseCache encoding:NSUTF8StringEncoding],YES);
                    }
                    
                }
            } success:^(id  _Nonnull responseObject) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    if (cache) {
                        cache([self jsonToString:responseObject],YES);
                    }
                } else if([responseObject isKindOfClass:[NSData class]]) {
                    if (cache) {
                        cache([[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding],YES);
                    }
                    
                }
            } failure:^(NSError * _Nonnull error) {
                if (failure) {
                    failure([self jsonToString:error.userInfo],YES);
                }
            }];
        } else {//不带缓存
            [WYNetworkManage GET:url parameters:parameters success:^(id  _Nonnull responseObject) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    if (cache) {
                        cache([self jsonToString:responseObject],YES);
                    }
                } else if([responseObject isKindOfClass:[NSData class]]) {
                    if (cache) {
                        cache([[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding],YES);
                    }
                    
                }
            } failure:^(NSError * _Nonnull error) {
                if (failure) {
                    failure([self jsonToString:error.userInfo],YES);
                }
            }];
        }
    }else if([method isEqualToString:@"POST"]){
        if (bol) {//带缓存
            [WYNetworkManage POST:url parameters:parameters responseCache:^(id  _Nonnull responseCache) {
                if ([responseCache isKindOfClass:[NSDictionary class]]) {
                    if (cache) {
                        cache([self jsonToString:responseCache],YES);
                    }
                } else if([responseCache isKindOfClass:[NSData class]]) {
                    if (cache) {
                        cache([[NSString alloc] initWithData:responseCache encoding:NSUTF8StringEncoding],YES);
                    }
                    
                }
            } success:^(id  _Nonnull responseObject) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    if (cache) {
                        cache([self jsonToString:responseObject],YES);
                    }
                } else if([responseObject isKindOfClass:[NSData class]]) {
                    if (cache) {
                        cache([[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding],YES);
                    }
                    
                }
            } failure:^(NSError * _Nonnull error) {
                if (failure) {
                    failure([self jsonToString:error.userInfo],YES);
                }
            }];
        } else {//不带缓存
            [WYNetworkManage POST:url parameters:parameters success:^(id  _Nonnull responseObject) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    if (cache) {
                        cache([self jsonToString:responseObject],YES);
                    }
                } else if([responseObject isKindOfClass:[NSData class]]) {
                    if (cache) {
                        cache([[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding],YES);
                    }
                    
                }
            } failure:^(NSError * _Nonnull error) {
                if (failure) {
                    failure([self jsonToString:error.userInfo],YES);
                }
            }];
        }
    }
#else
    NSAssert(NO, @"请导入WYNetworkManager后再使用此功能");
#endif
}

#pragma mark ------------------公共参数设置----------------------
/**
 *  设置网络请求参数的格式:默认为二进制格式
 *
 *  @param requestSerializer WYRequestSerializerJSON(JSON格式),WYRequestSerializerHTTP(二进制格式),
 */
- (void)setRequestSerializer:(NSString *)serializer {
#if __has_include(<WYNetworkManage.h>) || __has_include("WYNetworkManage.h")
    if ([serializer isEqualToString:@"JSON"]) {
        [WYNetworkManage setRequestSerializer:WYRequestSerializerJSON];
    } else if ([serializer isEqualToString:@"HTTP"]) {
        [WYNetworkManage setRequestSerializer:WYRequestSerializerHTTP];
    }
#else
    NSAssert(NO, @"请导入WYNetworkManager后再使用此功能");
#endif
}

/**
 *  设置服务器响应数据格式:默认为JSON格式
 *
 *  @param responseSerializer WYResponseSerializerJSON(JSON格式),WYResponseSerializerHTTP(二进制格式)
 */
- (void)setResponseSerializer:(NSString *)serializer {
#if __has_include(<WYNetworkManage.h>) || __has_include("WYNetworkManage.h")
    if ([serializer isEqualToString:@"JSON"]) {
        [WYNetworkManage setResponseSerializer:WYResponseSerializerJSON];
    } else if ([serializer isEqualToString:@"HTTP"]) {
        [WYNetworkManage setResponseSerializer:WYResponseSerializerHTTP];
    }
#else
    NSAssert(NO, @"请导入WYNetworkManager后再使用此功能");
#endif
}

/**
 *  设置请求超时时间:默认为30S
 *
 *  @param time 时长
 */
- (void)setRequestTimeoutInterval:(NSString *)time {
#if __has_include(<WYNetworkManage.h>) || __has_include("WYNetworkManage.h")
    [WYNetworkManage setRequestTimeoutInterval:[time doubleValue]];
#else
    NSAssert(NO, @"请导入WYNetworkManager后再使用此功能");
#endif
}

/// 设置请求头
- (void)setValueForHTTPHeaderField:(NSDictionary *)dict {
    NSArray *allKeys = [dict allKeys];
    [allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [WYNetworkManage setValue:dict[allKeys[idx]] forHTTPHeaderField:allKeys[idx]];
    }];
}

/**
 *  是否打开网络状态转圈菊花:默认打开
 *
 *  @param open YES(打开), NO(关闭)
 */
- (void)openNetworkActivityIndicator:(NSString *)open {
#if __has_include(<WYNetworkManage.h>) || __has_include("WYNetworkManage.h")
    [WYNetworkManage openNetworkActivityIndicator:[open boolValue]];
#else
    NSAssert(NO, @"请导入WYNetworkManager后再使用此功能");
#endif
}

#pragma mark ------------------json转字符串---------------------
/**
 *  json转字符串
 */
- (NSString *)jsonToString:(NSDictionary *)dic
{
    if(!dic){
        return nil;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}



@end
