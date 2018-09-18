//
//  CMJFBaseNetworkingService.m
//  CMfspay
//
//  Created by 超盟 on 2017/12/1.
//  Copyright © 2017年 超盟. All rights reserved.
//

#import "CMJFBaseNetworkingService.h"
#import <MJExtension.h>
//#import "CMJFUUID.h"
#import "AppDelegate.h"
//#import "CMJFManager.h"
//#import "CMJFLoginVO.h"
//#import "XGPush.h"
//#import "CMJFTokenVO.h"
//#import "CMJFRequestHeader.h"
//#import "CMJFDnsHelper.h"
#import "WeexNativeSupport.h"
#import "CMJFNetworkHelper.h"
#define CKJFEncriptionSecurityKey @"C&h^%Me^&Fd%&ChAiN"

@implementation CMJFBaseNetworkingService

#pragma mark--post请求

static CMJFBaseNetworkingService *manager;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.requestSerializer =  [AFHTTPRequestSerializer serializer];
        //manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy; //缓存策略
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json",@"application/x-www-form-urlencoded; charset=UTF-8", @"text/html", nil];//支持类型
        // 设置超时时间
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 8.0f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        //https
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [securityPolicy setValidatesDomainName:NO];
        securityPolicy.allowInvalidCertificates = YES; //还是必须设成YES
        manager.securityPolicy = securityPolicy;
    });
    return manager;
}

+ (void)parameters:(id)parameters
              func:(NSString *)func
           baseUrl:(NSString *)baseUrl
       accessToken:(NSString *)accessToken
       contentType:(NSString *)contentType
    responseDecode:(BOOL)responseDecode
           success:(void (^)(NSURLSessionDataTask *operation, id result))requestSuccess
           failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))requestFailure
{
    NSMutableDictionary *pdic = parameters ? parameters : @{}.mutableCopy;
    NSString *bUrl = baseUrl ? baseUrl : @"";
    NSString *httpPath = func ? [NSString stringWithFormat:@"%@%@",bUrl,func] : bUrl;
    
    AFHTTPSessionManager *manager = [CMJFBaseNetworkingService shared];
    
    
    CMJFNetworkHelper *helper = [CMJFNetworkHelper shareHelper];
    NSString *network;
    if (helper.cmNetWorkStatus == CMJF_WIFI) {
        network = @"wifi";
    }else if(helper.cmNetWorkStatus == CMJF_WWAN){
        network = @"蜂窝";
    }else{
        network = @"未知";
    }
    NSString *user_agent = [NSString stringWithFormat:@"iOS/%@ Manufacture/apple Device/iPhone CMMerchant/%@ NetType/%@",[NSString stringWithFormat:@"%.1f",ios_version],CMJFlocalVersion,network];
    [manager.requestSerializer setValue:user_agent forHTTPHeaderField:@"User-Agent"];
    NSArray *urls = [bUrl componentsSeparatedByString:@"://"];
    if (urls.count > 1) {
        NSString *host = urls[1];
        [manager.requestSerializer setValue:host forHTTPHeaderField:@"host"];
    }
    
    [pdic setObject:@"IOS" forKey:@"versions"];
    [pdic setObject:@"110" forKey:@"vertype"];
    [pdic setObject:CMJFlocalVersion forKey:@"ver"];
    
    
    NSString *jsonString = [pdic mj_JSONString];
    jsonString = [CMJFEncriptionHelper HloveyRC4:jsonString key:CKJFEncriptionSecurityKey];
    
    //    NSDictionary *bodyDic = @{@"iOS_key":jsonString};
    //
    //    if (contentType) {
    //        bodyDic = [NSDictionary dictionaryWithDictionary:pdic];
    //    }
    //    else{
    //        NSString *jsonString = [NSString convertToJsonData:pdic];
    //        NSLog(@"----%@",jsonString);
    //        jsonString = [CMJFEncriptionHelper HloveyRC4:jsonString key:CKJFEncriptionSecurityKey];
    //        NSLog(@"--%@",jsonString);
    //        bodyDic = @{@"iOS_key":jsonString};
    //    }
    
    
    [manager POST:httpPath parameters:jsonString progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseDecode) {
            NSString *messageInfo = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"----%@",messageInfo);
            NSString *base64Decoded = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:messageInfo options:0] encoding:NSUTF8StringEncoding];
            NSLog(@"Decoded: %@", base64Decoded);
            responseObject = [CMJFEncriptionHelper rc4Decode:messageInfo key:CKJFEncriptionSecurityKey];
        }
        
        requestSuccess(task,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求错误------------------------------\n%@",error.description);
        if (requestFailure) {
            if (!contentType) {
                if (error.code == -1001) {
                    [SVProgressHUD showErrorWithStatus:@"请求超时"];
                }else if (error.code == -1011){
                    [SVProgressHUD showErrorWithStatus:@"系统繁忙，请稍后重试[500]"];
                }else{
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@[%ld]",[error userInfo][@"NSLocalizedDescription"]?[error userInfo][@"NSLocalizedDescription"]:@"",(long)error.code]];
                }
            }
            requestFailure(task,error);
        }
        
    }];
}

//#pragma mark get请求
//+ (void)getMsgWithBaseUrl:(NSString *)baseUrl
//                     func:(NSString *)func
//               parameters:(NSDictionary *)parameters
//              accessToken:(NSString *)accessToken
//                 needShow:(NSString *)needShow
//                  success:(void (^)(NSURLSessionDataTask *operation, id result))requestSuccess
//                  failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))requestFailure
//{
//
//
//    manager.requestSerializer.timeoutInterval = 10.f;
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript",@"image/jpg",@"image/png", nil];
//    if (accessToken) {
//        [manager.requestSerializer setValue:accessToken forHTTPHeaderField:@"Token"];
//    }
//    NSString *bUrl = nil;
//    if (baseUrl) {
//        bUrl = baseUrl;
//    }
//    else{
//        bUrl = kBaseUrl_1;
//    }
//
//    NSString *httpPath = bUrl;
//    if (func.length > 0) {
//        httpPath = [NSString stringWithFormat:@"%@%@",bUrl,func];
//    }
//    NSLog(@"请求信息：%@\n bodyMsg=%@", httpPath, parameters);
//    NSDictionary *pdic  = nil;
//    if (parameters) {
//        pdic = parameters;
//    }
//    else{
//        pdic = @{};
//    }
//
//    [manager GET:httpPath parameters:pdic progress:^(NSProgress * _Nonnull downloadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        id dic = nil;
//        NSError *error = nil;
//        if (responseObject != nil && ![responseObject isKindOfClass:[NSDictionary class]]) {
//            dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
//        }else{
//            dic = responseObject;
//        }
//        if (error != nil) {
//            NSLog(@"解析错误------------------------------\n%@",error.description);
//        }else{
//            NSLog(@"返回结果%@ ========================\n%@",httpPath, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
//        }
//        if (requestSuccess) {
//            if (dic == nil || [dic isKindOfClass:[NSNull class]]) {
//                dic = @{};
//            }
//
//            if ([[NSString stringWithFormat:@"%@",dic[@"code"]] isEqualToString:@"888"]) {
//                [self reLoginWithMsg:@"登录信息已过期,请重新登录！"];
//            }
//            else{
//
//            }
//
//            requestSuccess(task,dic);
//
//        }
//
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"--------请求错误：%@",error.description);
//        if (requestFailure) {
//            if (!needShow) {
//                if (error.code == -1001) {
//                    [SVProgressHUD showInfoWithStatus:@"请求超时"];
//                }
//                else if (error.code == -1011){
//                    [SVProgressHUD showInfoWithStatus:@"请求错误[code:500]"];
//                }
//                else{
//                    [SVProgressHUD showErrorWithStatus:@"请求错误"];
//                }
//            }
//            requestFailure(task,error);
//        }
//    }];
//}



//1.获取登陆请求成功后保存的cookies
+ (NSString *)cookieValueWithKey:(NSString *)key
{
    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    if ([sharedHTTPCookieStorage cookieAcceptPolicy] != NSHTTPCookieAcceptPolicyAlways) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    }
    
    NSArray         *cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:@"http://192...."]];
    NSEnumerator    *enumerator = [cookies objectEnumerator];
    NSHTTPCookie    *cookie;
    while (cookie = [enumerator nextObject]) {
        if ([[cookie name] isEqualToString:key]) {
            return [NSString stringWithString:[[cookie value] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    return nil;
}

//2.删除cookies (key所对应的cookies) ///因为cookies保存在NSHTTPCookieStorage.cookies中.这里删除它里边的元素即可.
+ (void)deleteCookieWithKey:(NSString *)key
{
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [NSArray arrayWithArray:[cookieJar cookies]];
    for (NSHTTPCookie *cookie in cookies) {
        if ([[cookie name] isEqualToString:key]) {
            [cookieJar deleteCookie:cookie];
        }
    }
}

+ (void)deleteAllCookies{
//    NSURL *url = [NSURL URLWithString:kBaseUrl_1];
//    if (url) {
//        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
//        for (int i = 0; i < [cookies count]; i++) {
//            NSHTTPCookie *cookie = (NSHTTPCookie *)[cookies objectAtIndex:i];
//            NSLog(@"cookie%@",cookie);
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
//
//        }
//    }
}

+ (void)reLoginWithMsg:(NSString *)msg{
//    [FGGProgressHUD showErrorWithStatus:msg];
//    NSString *uid = getUserDefaults(kUid);
//    [[XGPushTokenManager defaultTokenManager] unbindWithIdentifer:uid type:XGPushTokenBindTypeAccount];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [CMJFBaseNetworkingService deleteAllCookies];
//        [CMJFManager shareInstance].loginVO = nil;
//        kUserDefaults(@"", kLoginVO);
//        kUserDefaults(@"", kUid);
//        kUserDefaults(@"", kToken);
//        kUserDefaults(@"", CMJFSid);
//        kUserDefaults(@"", CMJFStaffPwd);
//        kUserDefaults(@"", CMJFPwd);
//        kUserDefaults(@"", CMJFRole);
//        kUserDefaults(@(-1234), CMJFFirstApplyStatus);
//        kUserSynchronize;
//
//        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        HYHYNavigationController *loginNav = [[HYHYNavigationController alloc] initWithRootViewController:[[CMJFLoginViewController alloc] init]];
//        delegate.window.rootViewController = loginNav;
//    });
}

+ (NSString *)imgDataDeal:(NSData *)img_data{
    NSString *base64Str = [img_data base64EncodedStringWithOptions:0];
    NSString *appendStr = [NSString stringWithFormat:@"data:image/jpeg;base64,%@",base64Str];
    return appendStr;
}

@end
