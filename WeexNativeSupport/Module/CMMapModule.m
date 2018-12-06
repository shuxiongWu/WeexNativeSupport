//
//  CMMapModule.m
//  WeexDemo
//
//  Created by 超盟 on 2018/11/7.
//  Copyright © 2018年 wushuxiong. All rights reserved.
//

#import "CMMapModule.h"
//#import "MapViewCtl.h"
//#import <WeexSDK/WeexSDK.h>
//@interface CMMapModule ()
//@property (nonatomic, copy) WXModuleKeepAliveCallback locationCallBack;
//@property (nonatomic, strong) MapViewCtl *mapCtl;
//@end
//
//@implementation CMMapModule
//@synthesize weexInstance;
////地图定位页面
//WX_EXPORT_METHOD(@selector(pushToCtrlGetLocation:))
//
//+ (void)load{
//    [WXSDKEngine registerModule:@"CMMapModule" withClass:[CMMapModule class]];
//}
//
//#pragma mark -- 地图定位
//- (void)pushToCtrlGetLocation:(WXModuleKeepAliveCallback)callBack{
//    self.locationCallBack = callBack;
//   // [weexInstance.viewController.navigationController setNavigationBarHidden:NO animated:YES];
//    [weexInstance.viewController.navigationController pushViewController:self.mapCtl animated:YES];
//
//    //[[[UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers firstObject] presentViewController:self.mapCtl animated:YES completion:nil];
//}
//
//- (MapViewCtl *)mapCtl
//{
//    if (!_mapCtl) {
//        _mapCtl = [[MapViewCtl alloc] initWithNibName:NSStringFromClass([MapViewCtl class]) bundle:nil];
//        __weak typeof(self)weakSelf = self;
//        _mapCtl.locationAddressBlk = ^(double longitude, double latitude, NSString *address, NSString *detailAddress) {
//            weakSelf.locationCallBack ? weakSelf.locationCallBack(@{@"longitude": @(longitude), @"latitude": @(latitude), @"address": address, @"detailAddress": detailAddress}, YES) : nil;
//        };
//    }
//    return _mapCtl;
//}

//@end
