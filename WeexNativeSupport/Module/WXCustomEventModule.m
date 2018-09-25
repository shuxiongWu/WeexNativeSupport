//
//  WXCustomEventModule.m
//  WeexDemo
//
//  Created by cm on 2018/6/23.
//  Copyright © 2018年 taobao. All rights reserved.
//

#import "WXCustomEventModule.h"
#import <WeexSDK/WXModuleProtocol.h>
#import <WeexSDK/WXExceptionUtils.h>
#import <WeexSDK/WeexSDK.h>
#import <WeexSDK/WXUtility.h>
#import "WeexNativeSupport.h"
#import "WeexNativeSupportManage.h"

@interface WXCustomEventModule ()

@property (nonatomic, strong) WeexNativeSupportManage *nativeManage;                                      //weex原生支持管理类

@end

@implementation WXCustomEventModule
@synthesize weexInstance;

//拍照
WX_EXPORT_METHOD(@selector(addImgs:))

//从相册中选取照片
WX_EXPORT_METHOD(@selector(addphoto:callBack:))

//地图定位页面
WX_EXPORT_METHOD(@selector(getLocation:))

//链接到超盟商家
WX_EXPORT_METHOD(@selector(jumpTocmshop:))

//打电话
WX_EXPORT_METHOD(@selector(call:))

//二维码扫描
WX_EXPORT_METHOD(@selector(scanQR:))

////蓝牙管理类相关api
WX_EXPORT_METHOD(@selector(beginScanPerpheral:))            //扫描
WX_EXPORT_METHOD(@selector(autoConnectLastPeripheral:))     //自动连接
WX_EXPORT_METHOD(@selector(connectPeripheral:callBack:))    //手动连接
WX_EXPORT_METHOD(@selector(bluetoothPrinte:callBack:))      //蓝牙打印

//WIFI相关api
WX_EXPORT_METHOD(@selector(getSSIDInfo:))

//日志上传
WX_EXPORT_METHOD(@selector(upLoadLogInfo:))
WX_EXPORT_METHOD(@selector(printeLogInfoWithLog:callBack:))

//版本更新
WX_EXPORT_METHOD(@selector(checkVersion:callBack:))
WX_EXPORT_METHOD(@selector(getVersion:))
WX_EXPORT_METHOD(@selector(updateApp:))

//打开淘宝领优惠券
WX_EXPORT_METHOD(@selector(getCoupon:callBack:))

//分享
WX_EXPORT_METHOD(@selector(activityShareWithImageUrlArray:callBack:))

//截屏保存图片
WX_EXPORT_METHOD(@selector(captureImageFromViewAndSavePhoto:))

//数据存储
WX_EXPORT_METHOD(@selector(saveDataWithObject:callBack:))
WX_EXPORT_METHOD(@selector(getValueForKey:callBack:))

//路由跳转
WX_EXPORT_METHOD(@selector(popToAppointControllerForAcount:callBack:))
WX_EXPORT_METHOD(@selector(deleteNavigatorTrackAtLocation:andLength:callBack:))


+ (void)load{
    [WXSDKEngine registerModule:@"event" withClass:[WXCustomEventModule class]];
}

#pragma mark -- 从相册选取照片
- (void)addphoto:(NSInteger)num callBack:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage selectPhotoFromPhotoAlbumOfNum:num callBack:callBack];
}

#pragma mark -- 拍照
- (void)addImgs:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage photograph:callBack];
}
#pragma mark -- 地图定位
- (void)getLocation:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage getLocation:callBack];
}

#pragma mark -- 链接到超盟商家
- (void)jumpTocmshop:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage jumpTocmshop:callBack];
}

#pragma mark -- 打电话
-(void)call:(NSString*)num{
    NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"tel:%@",num];
    UIWebView *callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [weexInstance.viewController.view addSubview:callWebview];
}

#pragma mark -- 二维码扫描
- (void)scanQR:(WXModuleKeepAliveCallback)callBack
{
    [self.nativeManage scanQR:callBack];
}

#pragma mark -- 存储数据
- (void)saveDataWithObject:(NSDictionary *)dict callBack:(WXModuleKeepAliveCallback)callBack{
    [[NSUserDefaults standardUserDefaults] setValue:dict[@"value"] forKey:dict[@"key"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -- 拿取数据
- (void)getValueForKey:(NSString *)key callBack:(WXModuleKeepAliveCallback)callBack{
    callBack([[NSUserDefaults standardUserDefaults] valueForKey:key],YES);
}

#pragma mark -- 开始扫描
- (void)beginScanPerpheral:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage beginScanPerpheral:callBack];
}

#pragma mark -- 自动连接蓝牙
- (void)autoConnectLastPeripheral:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage autoConnectLastPeripheral:callBack];
}

#pragma mark -- 手动连接
- (void)connectPeripheral:(NSInteger)index callBack:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage connectPeripheral:index callBack:callBack];
}

#pragma mark -- 蓝牙打印小票
- (void)bluetoothPrinte:(id)dict callBack:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage bluetoothPrinte:dict callBack:callBack];
}


#pragma mark -- 检查更新
- (void)checkVersion:(NSString *)appId callBack:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage checkVersionToUpdateWithUrl:nil appId:appId isShowLatestVersionTips:YES];
}

#pragma mark -- 获取版本号
- (void)getVersion:(WXModuleKeepAliveCallback)callBack{
    callBack([[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"], YES);
}

#pragma mark -- 去商店更新
- (void)updateApp:(NSString *)appId{
    NSString *itunsStr = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/us/id%@?mt=8",appId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itunsStr]];
}

#pragma mark -- 淘宝优惠券
- (void)getCoupon:(NSString *)string callBack:(WXModuleKeepAliveCallback)callBack{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}

#pragma mark--获取ssid信息
- (void)getSSIDInfo:(WXModuleKeepAliveCallback)callBack {
    [self.nativeManage getSSIDInfo:callBack];
}

#pragma mark --上传日志

- (void)upLoadLogInfo:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage upLoadLogInfo];
}


#pragma mark -- 日志打印
- (void)printeLogInfoWithLog:(id)log callBack:(WXModuleKeepAliveCallback)callBack{
    DDLogDebug(@"%@",log);
}

#pragma mark -- 分享纯图片
- (void)activityShareWithImageUrlArray:(NSArray *)urlArray callBack:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage activityShareWithImageUrlArray:urlArray];
}

#pragma mark -- 截屏并保存图片
- (void)captureImageFromViewAndSavePhoto:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage captureImageFromViewAndSavePhotoWithCurrentView:weexInstance.viewController.view];
}

#pragma mark -- 导航跳转之页面回退
- (void)popToAppointControllerForAcount:(NSInteger)count callBack:(WXModuleKeepAliveCallback)callBack{
    if (count < 1) {
        return;
    }
    NSMutableArray *arr = [NSMutableArray arrayWithArray:weexInstance.viewController.navigationController.viewControllers];
    if (count > arr.count) {
        return;
    }
    for (NSInteger i = 0; i < count; i ++) {
        [arr removeObjectAtIndex:arr.count - 1];
    }
    weexInstance.viewController.navigationController.viewControllers = arr;
    [weexInstance.viewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 导航跳转之销毁页面区间
- (void)deleteNavigatorTrackAtLocation:(NSInteger)loc andLength:(NSInteger)length callBack:(WXModuleKeepAliveCallback)callBack{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:weexInstance.viewController.navigationController.viewControllers];
    if (loc + length >= arr.count) {
        return;
    }
    [arr removeObjectsInRange:NSMakeRange(loc, length)];
}

#pragma mark -- setter\getter

- (WeexNativeSupportManage *)nativeManage{
    return [WeexNativeSupportManage shareManage];
}

@end
