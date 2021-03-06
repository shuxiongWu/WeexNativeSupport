//
//  WeexNativeSupportManage.h
//  WeexDemo
//
//  Created by 超盟 on 2018/9/14.
//  Copyright © 2018年 wusx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WeexSDK/WeexSDK.h>
@interface WeexNativeSupportManage : NSObject<WXModuleProtocol>
//初始化管理类
+ (instancetype)shareManage;

/**
 检查版本更新

 @param url 版本控制的url
 @param appId APPID
 @param isShow 是否显示最新版本提示
 */
- (void)checkVersionToUpdateWithUrl:(NSString *)url
                              appId:(NSString *)appId
                              isShowLatestVersionTips:(BOOL)isShow;


/**
 图片分享

 @param urlArray 网络图片路径
 */
- (void)activityShareWithImageUrlArray:(NSArray *)urlArray;


/**
 截屏保存图片

 @param view 当前需要截取的屏
 */
- (void)captureImageFromViewAndSavePhotoWithCurrentView:(UIView *)view;


/**
 上传保存在本地的日志
 */
- (void)upLoadLogInfo;


/**
 //获取WiFi SSID

 @param callBack 回调
 */
- (void)getSSIDInfo:(WXModuleKeepAliveCallback)callBack;



/**
 二维码扫描

 @param callBack 回调
 */
- (void)scanQR:(WXModuleKeepAliveCallback)callBack;


/**
 链接到超盟商家

 @param callBack 回调
 */
- (void)jumpTocmshop:(WXModuleKeepAliveCallback)callBack;

/**
 拍照

 @param callBack 回调
 */
- (void)photograph:(WXModuleKeepAliveCallback)callBack;


/**
 拍照

 @param parame 传入参数（是否需要裁剪，裁剪比例,是否可移动裁剪框）
 @param callBack 回调
 */
- (void)photographWithParameter:(NSDictionary *)parame callBack:(WXModuleKeepAliveCallback)callBack;

/**
 从相册选取照片

 @param num 需要照片数量
 @param callBack 回调
 */
- (void)selectPhotoFromPhotoAlbumOfNum:(NSInteger)num callBack:(WXModuleKeepAliveCallback)callBack;


/**
 从相册选取照片
 
 @param num 传入参数（是否需要裁剪，裁剪比例,是否可移动裁剪框）
 @param callBack 回调
 */
- (void)selectPhotoFromPhotoAlbum:(NSDictionary *)params callBack:(WXModuleKeepAliveCallback)callBack;


/**
 将图片存入相册

 @param image image
 */
- (void)savePhotoToMediaLibraryWithImage:(UIImage *)image;

/**
 打开第三方应用

 @param urlSchemes urlSchemes
 @param callBack callBack description
 */
- (void)openThirdApplication:(NSString *)urlSchemes callBack:(WXModuleKeepAliveCallback)callBack;
@end
