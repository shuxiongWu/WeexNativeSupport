//
//  CMJFBaseNetworkingService.h
//  CMfspay
//
//  Created by 超盟 on 2017/12/1.
//  Copyright © 2017年 超盟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "NSMutableDictionary+CMJFDicEnctription.h"
#import "CMJFEncriptionHelper.h"
typedef void (^completeHandle)(id data,id msg);
typedef void (^failureHandle)(id error);
typedef void (^successHandle)(id data,id msg,id is_force);
@interface CMJFBaseNetworkingService : AFHTTPSessionManager

/**  post
 *   parameters 参数dic
 *   func 路由
 *   baseUrl
 *   accessToken token
 *   contentType content-type类型
 *   responseDecode 响应数据是否需要解密
 *   requestSuccess 请求成功回调
 *   requestFailure 请求失败回调
 */
+ (void)parameters:(id)parameters
              func:(NSString *)func
           baseUrl:(NSString *)baseUrl
       accessToken:(NSString *)accessToken
       contentType:(NSString *)contentType
    responseDecode:(BOOL)responseDecode
           success:(void (^)(NSURLSessionDataTask *operation, id result))requestSuccess
           failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))requestFailure;

//+ (void)getMsgWithBaseUrl:(NSString *)baseUrl
//                     func:(NSString *)func
//               parameters:(NSDictionary *)parameters
//              accessToken:(NSString *)accessToken
//                 needShow:(NSString *)needShow
//                  success:(void (^)(NSURLSessionDataTask *operation, id result))requestSuccess
//                  failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))requestFailure;


//清除cookie
+ (void)deleteCookieWithKey:(NSString *)key;

//清除所有cookie
+ (void)deleteAllCookies;

//图片data转base64
+ (NSString *)imgDataDeal:(NSData *)img_data;

@end
