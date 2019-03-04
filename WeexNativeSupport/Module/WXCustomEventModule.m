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
#import "WeexLocationManage.h"
#import <AudioToolbox/AudioServices.h>
#if __has_include(<SDWebImage/SDWebImageManager.h>)
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>
#elif __has_include("SDWebImageManager.h")
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#endif
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <SVProgressHUD.h>


//#import "WXDemoViewController.h"
@interface WXCustomEventModule ()

@property (nonatomic, strong) WeexNativeSupportManage *nativeManage;                                      //weex原生支持管理类
@property (nonatomic, copy) WXModuleKeepAliveCallback sanqrCallBack;
@property (nonatomic, strong) WeexQRViewController *scanQRCtl;
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
WX_EXPORT_METHOD(@selector(getPageSize:))

//设置状态栏颜色
WX_EXPORT_METHOD(@selector(setStatusBarColor:))

//保存图片到相册
WX_EXPORT_METHOD(@selector(savePhotos:callBack:))

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
    [[WeexLocationManage shareManage] startLocation];
    [[WeexLocationManage shareManage] setLocationCallBack:callBack];
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
    
    if ([baseString containsString:@"http"]) {
#if __has_include(<SDWebImage/SDWebImageManager.h>) || __has_include("SDWebImageManager.h")
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        UIImage *image = [[manager imageCache] imageFromDiskCacheForKey:baseString];
        [self.nativeManage savePhotoToMediaLibraryWithImage:image];
#else
        NSAssert(NO, @"请导入SDWebImage后再使用网络图片功能");
#endif
    }else{
        NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:baseString options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
        UIImage *decodedImage = [UIImage imageWithData: decodeData];
        [self.nativeManage savePhotoToMediaLibraryWithImage:decodedImage];
    }
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
    weexInstance.viewController.navigationController.viewControllers = arr;
}

#pragma mark -- 获取当前导航栈控制器数量
- (void)getPageSize:(WXModuleKeepAliveCallback)callBack{
    if (callBack) {
        callBack(@(weexInstance.viewController.navigationController.viewControllers.count),YES);
    }
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

#pragma mark -- 设置状态栏颜色
- (void)setStatusBarColor:(NSString *)color {
    if ([color isEqualToString:@"black"]) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
}

#pragma mark ---------------------保存图片到相册---------------------
- (void)savePhotos:(NSArray *)array callBack:(WXModuleKeepAliveCallback)callBack {
    
    __block BOOL fail = NO;
    __block NSInteger index = 0;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        //无权限
        [SVProgressHUD showInfoWithStatus:@"请先配置访问权限"];
        return;
    }
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *urlString = array[idx];
        if ([urlString containsString:@"http"]) {//网络地址
#if __has_include(<SDWebImage/SDWebImageManager.h>) || __has_include("UIImageView+WebCache.h")
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:array[idx]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                __block ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
                [lib writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        fail = YES;
                    }
                    index ++;
                    if (index == array.count) {
                        if (callBack) {
                            callBack(@"1",YES);
                        }
                    }
                }];
            }];
#else
            NSAssert(NO, @"请导入SDWebImage后再使用网络图片功能");
#endif
        }else {//base64图片字符串
            NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:urlString options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
            UIImage *decodedImage = [UIImage imageWithData: decodeData];
            __block ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            [lib writeImageToSavedPhotosAlbum:decodedImage.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    fail = YES;
                }
                index ++;
            }];
        }
        
    }];
    

}

#pragma mark -- setter\getter

- (WeexNativeSupportManage *)nativeManage{
    return [WeexNativeSupportManage shareManage];
}

- (WeexQRViewController *)scanQRCtl
{
    NSString* bundlePath = [[NSBundle mainBundle] pathForResource: @"HXPhotoPicker"ofType:@"bundle"];
    
    NSBundle *resourceBundle =[NSBundle bundleWithPath:bundlePath];
    
    _scanQRCtl = [[WeexQRViewController alloc] initWithNibName:@"WeexQRViewController" bundle:resourceBundle];
    __weak typeof(self)weakSelf = self;
    _scanQRCtl.scanCallBack = ^(int code, NSString *msg) {
        weakSelf.sanqrCallBack ? weakSelf.sanqrCallBack(@{@"code": @(code),@"code_url": msg}, YES) : nil;
    };
    
    return _scanQRCtl;
}

@end

