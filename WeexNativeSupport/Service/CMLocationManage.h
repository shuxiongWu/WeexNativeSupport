//
//  CMLocationManage.h
//  WeexDemo
//
//  Created by 超盟 on 2018/9/26.
//  Copyright © 2018年 wusx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>      //添加定位服务头文件（不可缺少）
#import <WeexSDK/WXModuleProtocol.h>
@interface CMLocationManage : NSObject

@property (nonatomic, copy) WXModuleKeepAliveCallback locationCallBack;

+ (instancetype)shareManage;
//开始定位
- (void)startLocation;
@end
