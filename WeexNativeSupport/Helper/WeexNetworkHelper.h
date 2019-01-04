//
//  CMJFNetworkHelper.h
//  CMfspay
//
//  Created by fuguoguo on 2018/1/24.
//  Copyright © 2018年 mrchabao. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    CMJF_UNKNOWN,//未知
    CMJF_NotReachable,//没有网
    CMJF_WIFI,//Wi-Fi
    CMJF_WWAN,//蜂窝
} CMnetworkStatus;
@interface WeexNetworkHelper : NSObject
@property(nonatomic,assign)CMnetworkStatus cmNetWorkStatus;

+ (instancetype)shareHelper;

- (void)monitorNetwork;
@end
