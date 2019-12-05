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
#import <UserNotifications/UserNotifications.h>
#import <StoreKit/StoreKit.h>
#import <MJExtension.h>

//#import "WXDemoViewController.h"
@interface WXCustomEventModule ()

@property (nonatomic, strong) WeexNativeSupportManage *nativeManage;                                      //weex原生支持管理类
@property (nonatomic, copy) WXModuleKeepAliveCallback sanqrCallBack;
@property (nonatomic, copy) WXModuleKeepAliveCallback downloadImageCallback;
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
WX_EXPORT_METHOD(@selector(getLocationWithType:callBack:))

//链接到超盟商家
WX_EXPORT_METHOD(@selector(jumpTocmshop:))

//链接到外部应用
WX_EXPORT_METHOD(@selector(openThirdApplication:callBack:))

//打电话
WX_EXPORT_METHOD(@selector(call:))

//二维码扫描
WX_EXPORT_METHOD(@selector(scanQR:))
WX_EXPORT_METHOD(@selector(scanTitleQR:callback:))


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

//查询通知权限
WX_EXPORT_METHOD(@selector(getNotificationSettings:))

//打开APP设置页面
WX_EXPORT_METHOD(@selector(openSettings))

//撰写评论
WX_EXPORT_METHOD(@selector(writeReviews:))

//复制字符串到剪切板
WX_EXPORT_METHOD(@selector(copyStringToPasteboard:))
WX_EXPORT_METHOD(@selector(copyStringsToPasteboard:))

//获取剪切板的字符串
WX_EXPORT_METHOD(@selector(getPasteboardString:))
WX_EXPORT_METHOD(@selector(getPasteboardStrings:))

//下载网络图片到相册
WX_EXPORT_METHOD(@selector(downloadImageWithUrl:callback:))


+ (void)load{
    [WXSDKEngine registerModule:@"event" withClass:[WXCustomEventModule class]];
}

//下载网络图片到相册
- (void)downloadImageWithUrl:(NSString *)urlString callback:(WXModuleKeepAliveCallback)callback {
    if (!urlString || ![urlString isKindOfClass:[NSString class]]) {
        if (callback) {
            callback([@{@"code":@"1",@"message":@"参数错误"} mj_JSONString],YES);
        }
        return;
    }
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
    UIImage *image = [UIImage imageWithData:data];
    if (!image) {
        if (callback) {
            callback([@{@"code":@"1",@"message":@"无法下载，请检查图片url"} mj_JSONString],YES);
        }
    }
    self.downloadImageCallback = callback;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
// 下载结果
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    if (self.downloadImageCallback) {
        if (error) {
            self.downloadImageCallback([@{@"code":@"1",@"message":@"保存到相册失败，请检查是否开启相册权限"} mj_JSONString],YES);
        } else {
            self.downloadImageCallback([@{@"code":@"0",@"message":@"保存成功"} mj_JSONString],YES);
        }
    }
}

- (void)copyStringToPasteboard:(NSString *)text {
    if (![text isKindOfClass:[NSString class]]) {
        return;
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = text;
}

- (void)copyStringsToPasteboard:(id)obj {
    if ([obj isKindOfClass:[NSString class]]) {
        obj = [obj mj_JSONObject];
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.strings = obj;
}

- (void)getPasteboardString:(WXModuleKeepAliveCallback)callback {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (callback) {
        callback(pasteboard.string, YES);
    }
}
- (void)getPasteboardStrings:(WXModuleKeepAliveCallback)callback {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (callback) {
        callback([pasteboard.strings mj_JSONString], YES);
    }
}

#pragma mark -- 撰写评论
- (void)writeReviews:(NSString *)appId {
    
    if (@available(iOS 10.3, *)) {
        [SKStoreReviewController requestReview];
    } else {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"喜欢“%@”吗？",app_Name] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"去评分" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review",appId]]];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"下次" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancel];
        [alert addAction:confirm];
        [weexInstance.viewController presentViewController:alert animated:YES completion:nil];
    }
    
}

#pragma mark -- 打开APP设置页面
- (void)openSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL: url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

#pragma mark -- 查询通知权限
- (void)getNotificationSettings:(WXModuleCallback)callBack {
    if (@available(iOS 10.0, *)) {
        
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            
            if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                if (callBack) {
                    callBack(@(YES));
                }
            } else {
                if (callBack) {
                    callBack(@(NO));
                }
            }
        }];
    } else {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (setting.types == UIUserNotificationTypeNone) {
            if (callBack) {
                callBack(@(NO));
            }
        } else {
            if (callBack) {
                callBack(@(YES));
            }
        }
    }
    
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
/// 建议使用👇的新api
- (void)getLocation:(WXModuleKeepAliveCallback)callBack{
    [[WeexLocationManage shareManage] startLocation];
    [[WeexLocationManage shareManage] setLocationCallBack:callBack];
}
/// type: baidu gaode gps
- (void)getLocationWithType:(NSString *)type callBack:(WXModuleKeepAliveCallback)callBack {
    [WeexLocationManage shareManage].type = type;
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

- (void)scanTitleQR:(id)params callback:(WXModuleKeepAliveCallback)callBack {
    
    NSDictionary *decodeParams;
    if ([params isKindOfClass:NSString.class]) {
        decodeParams = [params mj_JSONObject];
    } else if ([params isKindOfClass:NSDictionary.class]) {
        decodeParams = params;
    } else {
        if (callBack) {
            callBack([@{@"code":@"",@"message":@"参数错误"} mj_JSONString],YES);
        }
        return;
    }
    if (decodeParams[@"description"]) {
        self.scanQRCtl.descriptionString = decodeParams[@"description"];
    }
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


#pragma mark -- 检查更新
- (void)checkVersion:(NSDictionary *)params callBack:(WXModuleKeepAliveCallback)callBack{
    [self.nativeManage checkVersionToUpdateWithUrl:params[@"url"] appId:params[@"appid"] isShowLatestVersionTips:YES];
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
#if __has_include(<SDWebImage/SDWebImageManager.h>) || __has_include(<SDWebImage/UIImageView+WebCache.h>)
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:array[idx]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                //保存图片到【相机胶卷】
                /// 异步执行修改操作
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
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
            
            [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromImage:decodedImage];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
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

