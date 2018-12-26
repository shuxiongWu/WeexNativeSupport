//
//  CMMapModule.m
//  WeexDemo
//
//  Created by 超盟 on 2018/11/7.
//  Copyright © 2018年 wushuxiong. All rights reserved.
//

#import "CMMapModule.h"
#import "LocationViewController.h"
#import <WeexSDK/WeexSDK.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
@interface CMMapModule ()
@property (nonatomic, copy) WXModuleKeepAliveCallback locationCallBack;
@property (nonatomic, strong) LocationViewController *mapCtl;
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
    [AMapServices sharedServices].apiKey = apiKey;
    [AMapServices sharedServices].enableHTTPS = YES;
    self.locationCallBack = callBack;
    // [weexInstance.viewController.navigationController setNavigationBarHidden:NO animated:YES];
    [weexInstance.viewController.navigationController pushViewController:self.mapCtl animated:YES];
}

- (LocationViewController *)mapCtl
{
    NSString* bundlePath = [[NSBundle mainBundle]pathForResource: @"HXPhotoPicker"ofType:@"bundle"];
    
    NSBundle *resourceBundle =[NSBundle bundleWithPath:bundlePath];
    if (!_mapCtl) {
        _mapCtl = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:resourceBundle];
        __weak typeof(self)weakSelf = self;
        _mapCtl.locationAddressBlk = ^(double longitude, double latitude, NSString *address, NSString *detailAddress) {
            weakSelf.locationCallBack ? weakSelf.locationCallBack(@{@"longitude": @(longitude), @"latitude": @(latitude), @"address": address, @"detailAddress": detailAddress}, YES) : nil;
        };
    }
    return _mapCtl;
}

@end

