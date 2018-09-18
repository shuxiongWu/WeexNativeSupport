//
//  WeexNativeSupportManage.h
//  WeexDemo
//
//  Created by 超盟 on 2018/9/14.
//  Copyright © 2018年 wusx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeexNativeSupportManage : NSObject
//初始化管理类
+ (instancetype)shareManage;

/**
 检查版本更新

 @param url 版本控制的url
 @param appId APPID
 @param isShow 是否显示最新版本提示
 */
- (void)checkVersionToUpdateWithUrl:(NSString *)url
                              appId:(NSString *)appId
                              isShowLatestVersionTips:(BOOL)isShow;


/**
 图片分享

 @param urlArray 网络图片路径
 */
- (void)activityShareWithImageUrlArray:(NSArray *)urlArray;
@end
