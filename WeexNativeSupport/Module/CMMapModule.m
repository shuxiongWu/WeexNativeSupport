//
//  CMMapModule.m
//  WeexDemo
//
//  Created by 超盟 on 2018/11/7.
//  Copyright © 2018年 wushuxiong. All rights reserved.
//

#import "CMMapModule.h"
#import "WeexLocationViewController.h"
#import <WeexSDK/WeexSDK.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
@interface CMMapModule ()
@property (nonatomic, copy) WXModuleKeepAliveCallback locationCallBack;

@end

@implementation CMMapModule
@synthesize weexInstance;
//地图定位页面
WX_EXPORT_METHOD(@selector(pushToCtrlGetLocationWithKey:callBack:))

+ (void)load{
    [WXSDKEngine registerModule:@"CMMapModule" withClass:[CMMapModule class]];
}

#pragma mark -- 地图定位
- (void)pushToCtrlGetLocationWithKey:(NSString *)apiKey callBack:(WXModuleKeepAliveCallback)callBack{
    [AMapServices sharedServices].apiKey = apiKey;//@"b1c9a5ba1334a6827a6d06908764645b";
    [AMapServices sharedServices].enableHTTPS = YES;
    self.locationCallBack = callBack;
    
    NSString* bundlePath = [[NSBundle mainBundle]pathForResource: @"HXPhotoPicker"ofType:@"bundle"];
    NSBundle *resourceBundle =[NSBundle bundleWithPath:bundlePath];
    WeexLocationViewController *mapVC = [[WeexLocationViewController alloc] initWithNibName:@"WeexLocationViewController" bundle:resourceBundle];
    __weak typeof(self)weakSelf = self;
    mapVC.locationAddressBlk = ^(double longitude, double latitude ,NSString *province ,NSString *city ,NSString *area ,NSString *address, NSString *detailAddress) {
        weakSelf.locationCallBack ? weakSelf.locationCallBack(@{
                                                                    @"longitude": @(longitude),
                                                                    @"latitude": @(latitude),
                                                                    @"province":province,
                                                                    @"city":city,
                                                                    @"area":area,
                                                                    @"address": address,
                                                                    @"detailAddress": detailAddress
                                                                }, YES) : nil;
    };
    
    [weexInstance.viewController.navigationController pushViewController:mapVC animated:YES];
}

@end

