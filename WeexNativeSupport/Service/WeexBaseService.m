//
//  CMBaseService.m
//  WeexDemo
//
//  Created by 超盟 on 2018/9/10.
//  Copyright © 2018年 wushuxiong. All rights reserved.
//

#import "WeexBaseService.h"
#import <SVProgressHUD/SVProgressHUD.h>
@implementation WeexBaseService
    //获取版本信息
+ (void)getAppVersionWithUrl:(NSString *)url
     isShowLatestVersionTips:(BOOL)isShow
                     success:(successHandle)success
                     failure:(failureHandle)failure{
    
    [WeexBaseNetworkingService parameters:nil func:nil baseUrl:url accessToken:nil contentType:nil responseDecode:YES success:^(NSURLSessionDataTask *operation, id result) {
        if ([[NSString stringWithFormat:@"%@",result[@"result"]] isEqualToString:@"1"]) {
            id data = result[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSString *newVersion = data[@"version"];
                //获取本地软件的版本号
                NSString *localVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                
                if ([newVersion isKindOfClass:[NSString class]] && [newVersion containsString:@"."]) {
                    NSArray *serverVersionArr = [newVersion componentsSeparatedByString:@"."];
                    NSArray *localVersionArr = [localVersion componentsSeparatedByString:@"."];
                    BOOL hasNewVersion = NO;
                    if (serverVersionArr.count && localVersionArr) {
                        for (int i = 0; i < serverVersionArr.count ; i++) {
                            if (i >= [localVersionArr count]) {
                                hasNewVersion = YES;
                                break;
                            }
                            if ([serverVersionArr[i] integerValue] > [localVersionArr[i] integerValue]) {
                                hasNewVersion = YES;
                                break;
                            }
                            if ([serverVersionArr[i] integerValue] < [localVersionArr[i] integerValue]) {
                                break;
                            }
                        }
                    }
                    //对比发现的新版本和本地的版本
                    success(data[@"content"]?data[@"content"]:@"",newVersion,data[@"is_force"]);
                }
            }
        }else{
            if (isShow) {
                [SVProgressHUD showSuccessWithStatus:@"当前已是最新版本"];
            }
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        failure(@"");
    }];
}
    @end
