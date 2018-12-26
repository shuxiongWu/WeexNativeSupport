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
#import "CMLocationManage.h"
#import <AudioToolbox/AudioServices.h>
#import "CMQRViewController.h"
//#import "WXDemoViewController.h"
@interface WXCustomEventModule ()

@property (nonatomic, strong) WeexNativeSupportManage *nativeManage;                                      //weex原生支持管理类
@property (nonatomic, copy) WXModuleKeepAliveCallback sanqrCallBack;
@property (nonatomic, strong) CMQRViewController *scanQRCtl;
@end

@implementation WXCustomEventModule
@synthesize weexInstance;

//拍照
WX_EXPORT_METHOD(@selector(addImgs:))
WX_EXPORT_METHOD(@selector(photographWithParameter:callBack:))

//从相册中选取照片
WX_EXPORT_METHOD(@selector(addphoto:callBack:))
WX_EXPORT_METHOD(@selector(selectPhotoFromPhotoAlbum:callBack:))

//定位（不需要地图）
WX_EXPORT_METHOD(@selector(getLocation:))

//链接到超盟商家
WX_EXPORT_METHOD(@selector(jumpTocmshop:))

//链接到外部应用
WX_EXPORT_METHOD(@selector(openThirdApplication:callBack:))

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

//截屏保存图片
WX_EXPORT_METHOD(@selector(captureImageFromViewAndSavePhoto:))
WX_EXPORT_METHOD(@selector(savePhotoToMediaLibraryWithImageBase64Data:))


//数据存储
WX_EXPORT_METHOD(@selector(saveDataWithObject:callBack:))
WX_EXPORT_METHOD(@selector(getValueForKey:callBack:))

//路由跳转
WX_EXPORT_METHOD(@selector(popToAppointControllerForAcount:callBack:))
WX_EXPORT_METHOD(@selector(deleteNavigatorTrackAtLocation:andLength:callBack:))

//短震（类似3D touch）
WX_EXPORT_METHOD(@selector(transientVibration))

//调节屏幕亮度
WX_EXPORT_METHOD(@selector(setBrightness:))

//present、dismiss
WX_EXPORT_METHOD(@selector(presentToController:))
WX_EXPORT_METHOD(@selector(dismiss))
WX_EXPORT_METHOD(@selector(getPageSize:))

//掉起第三方地图导航
WX_EXPORT_METHOD(@selector(getPageSize:))

+ (void)load{
    [WXSDKEngine registerModule:@"event" withClass:[WXCustomEventModule class]];
}

#pragma mark -- 从相册选取照片
- (void)addphoto:(NSInteger)num callBack:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage selectPhotoFromPhotoAlbumOfNum:num callBack:callBack];
}
//建议使用新的api
- (void)selectPhotoFromPhotoAlbum:(NSDictionary *)params callBack:(WXModuleKeepAliveCallback)callBack {
    [self.nativeManage selectPhotoFromPhotoAlbum:params callBack:callBack];
}

#pragma mark -- 拍照
- (void)addImgs:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage photograph:callBack];
}
//建议使用新的api
- (void)photographWithParameter:(NSDictionary *)parame callBack:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage photographWithParameter:parame callBack:callBack];
}

#pragma mark -- 定位(不通过地图)
- (void)getLocation:(WXModuleKeepAliveCallback)callBack{
    [[CMLocationManage shareManage] startLocation];
    [[CMLocationManage shareManage] setLocationCallBack:callBack];
}

#pragma mark -- 链接到超盟商家
- (void)jumpTocmshop:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage jumpTocmshop:callBack];
}

#pragma mark -- 链接到外部应用
- (void)openThirdApplication:(NSString *)urlSchemes callBack:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage openThirdApplication:urlSchemes callBack:callBack];
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
    //[self.nativeManage scanQR:callBack];
    self.sanqrCallBack = callBack;
    [weexInstance.viewController.navigationController pushViewController:self.scanQRCtl animated:YES];
}

#pragma mark -- 存储数据
- (void)saveDataWithObject:(NSDictionary *)dict callBack:(WXModuleKeepAliveCallback)callBack{
    [[NSUserDefaults standardUserDefaults] setValue:dict[@"value"] forKey:dict[@"key"]];
    BOOL bol = [[NSUserDefaults standardUserDefaults] synchronize];
    if (callBack) {
        callBack(@(bol),YES);
    }
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
    // DDLogDebug(@"%@",log);
}

#pragma mark -- 截屏并保存图片
- (void)captureImageFromViewAndSavePhoto:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage captureImageFromViewAndSavePhotoWithCurrentView:weexInstance.viewController.view];
}

- (void)savePhotoToMediaLibraryWithImageBase64Data:(NSString *)baseString{
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:baseString options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
    UIImage *decodedImage = [UIImage imageWithData: decodeData];
    [self.nativeManage savePhotoToMediaLibraryWithImage:decodedImage];
    
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

#pragma mark -- 获取当前导航栈控制器数量
- (void)getPageSize:(WXModuleKeepAliveCallback)callBack{
    callBack(@(weexInstance.viewController.navigationController.viewControllers.count),YES);
}

#pragma mark -- 短震（类似3D touch）
- (void)transientVibration{
    AudioServicesPlaySystemSound(1520);
}

#pragma mark -- 调节屏幕亮度
- (void)setBrightness:(CGFloat)brightness {
    //设置亮度
    [[UIScreen mainScreen] setBrightness:brightness];
}

- (void)presentToController:(NSString *)url{
    //    url = [@"${PODS_ROOT}/bundlejs" stringByAppendingString:url];
    //    NSURL *URL = [[NSURL alloc] initFileURLWithPath:url];
    //
    //    UIViewController *demo = [[WXDemoViewController alloc] init];
    //    ((WXDemoViewController *)demo).url = URL;
    //    [weexInstance.viewController.navigationController pushViewController:demo animated:YES];
    // [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:demo animated:YES completion:nil];
}

- (void)dismiss{
    
}

#pragma mark -- setter\getter

- (WeexNativeSupportManage *)nativeManage{
    return [WeexNativeSupportManage shareManage];
}

- (CMQRViewController *)scanQRCtl
{
    NSString* bundlePath = [[NSBundle mainBundle] pathForResource: @"HXPhotoPicker"ofType:@"bundle"];
    
    NSBundle *resourceBundle =[NSBundle bundleWithPath:bundlePath];
    
    _scanQRCtl = [[CMQRViewController alloc] initWithNibName:@"CMQRViewController" bundle:resourceBundle];
    __weak typeof(self)weakSelf = self;
    _scanQRCtl.scanCallBack = ^(int code, NSString *msg) {
        weakSelf.sanqrCallBack ? weakSelf.sanqrCallBack(@{@"code": @(code),@"code_url": msg}, YES) : nil;
    };
    
    return _scanQRCtl;
}

@end

