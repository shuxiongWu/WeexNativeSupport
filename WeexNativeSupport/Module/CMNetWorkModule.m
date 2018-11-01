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
#import "CMJFBaseNetworkingService.h"
@implementation CMNetWorkModule

//post请求
WX_EXPORT_METHOD(@selector(postNetworkRequestWithParams:callBack:))

+(void)load{
    [WXSDKEngine registerModule:@"CMNetWorkModule" withClass:[CMNetWorkModule class]];
}

- (void)postNetworkRequestWithParams:(NSDictionary *)params callBack:(WXKeepAliveCallback)callBack{
    if (![params isKindOfClass:[NSDictionary class]]) return;
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:params];
    [tempDict removeObjectsForKeys:@[@"host",@"url",@"isDecode"]];
    [CMJFBaseNetworkingService parameters:tempDict func:params[@"host"] baseUrl:params[@"url"] accessToken:nil contentType:nil responseDecode:params[@"isDecode"] success:^(NSURLSessionDataTask *operation, id result) {
        if (callBack) {
            callBack(result,YES);
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (callBack) {
            callBack(error,YES);
        }
    }];
}

@end
