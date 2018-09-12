//
//  CMJFNetworkHelper.m
//  CMfspay
//
//  Created by fuguoguo on 2018/1/24.
//  Copyright © 2018年 mrchabao. All rights reserved.
//

#import "CMJFNetworkHelper.h"
#import <AFNetworking/AFNetworking.h>
@implementation CMJFNetworkHelper

+ (instancetype)shareHelper{
    static dispatch_once_t onceToken;
    static CMJFNetworkHelper *helper;
    dispatch_once(&onceToken, ^{
        helper = [[CMJFNetworkHelper alloc] init];
    });
    return helper;
}

- (instancetype)init{
    if (self = [super init]) {
        [self monitorNetwork];
    }
    return self;
}

- (void)monitorNetwork{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                self.cmNetWorkStatus = CMJF_UNKNOWN;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                self.cmNetWorkStatus = CMJF_NotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                self.cmNetWorkStatus = CMJF_WIFI;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                self.cmNetWorkStatus = CMJF_WWAN;
                break;
            default:
                break;
        }
    }];
    [mgr startMonitoring];
}

@end
