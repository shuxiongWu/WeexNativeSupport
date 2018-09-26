//
//  WeexNativeSupportManage.m
//  WeexDemo
//
//  Created by 超盟 on 2018/9/14.
//  Copyright © 2018年 wusx. All rights reserved.
//

#import "WeexNativeSupportManage.h"
#import "CMBaseService.h"
#import "MJShareItem.h"
#import "UIImage+ScaleImage.h"
#import <SVProgressHUD.h>
#if __has_include(<SDWebImage/SDWebImageManager.h>)
#import <SDWebImage/SDWebImageManager.h>
#elif __has_include("SDWebImageManager.h")
#import "SDWebImageManager.h"
#endif
#import "UIImage+Capture.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "WeexNativeSupport.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <Photos/Photos.h>
#import "JWBluetoothManage.h"
#import "CMDateHelper.h"
#import <MJExtension.h>
#import "NSSQRViewController.h"
#import "MapViewCtl.h"
#import "HXPhotoPicker.h"
#import "CMJFEncriptionHelper.h"
#import "UIImage+XJSCompress.h"
#import "CMLocationManage.h"
#define scanMaxNumber 3                //扫描蓝牙最大次数
@interface WeexNativeSupportManage ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,HXAlbumListViewControllerDelegate>

@property (strong, nonatomic) HXPhotoManager *manager;
@property (strong, nonatomic) HXDatePhotoToolManager *toolManager;
    
@property (nonatomic, copy) NSString *url;  //存储域名
@property (nonatomic, strong) JWBluetoothManage * bluetoothManage;                                  //蓝牙管理类
@property (nonatomic, strong) NSMutableArray *buletoothDataArray;                                   //已扫描蓝牙设备集合
@property (nonatomic, assign) NSInteger scanNum;                                                    //当前已扫描次数
@property (nonatomic, strong) NSSQRViewController *scanQRCtl;
@property (nonatomic, strong) MapViewCtl *mapCtl;
@property (nonatomic, strong) UIImagePickerController *imagePickerCtl;

@property (nonatomic, copy) WXModuleKeepAliveCallback imageCallBack;
@property (nonatomic, copy) WXModuleKeepAliveCallback locationCallBack;
@property (nonatomic, copy) WXModuleKeepAliveCallback sanqrCallBack;
@end

@implementation WeexNativeSupportManage
@synthesize weexInstance;
static WeexNativeSupportManage *manager = nil;
+ (instancetype)shareManage {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        manager = [[WeexNativeSupportManage alloc] init];
    });
    return manager;
    
}
#pragma mark --检查更新
- (void)checkVersionToUpdateWithUrl:(NSString *)url appId:(NSString *)appId isShowLatestVersionTips:(BOOL)isShow{
    if (url) {
        _url = url;
    }else{
        NSLog(@"请在AppDelegate里面初始化检查更新");
        return;
    }
    [CMBaseService getAppVersionWithUrl:_url isShowLatestVersionTips:isShow success:^(id data, id msg, id is_force) {
        if ([[NSString stringWithFormat:@"%@",is_force] isEqualToString:@"1"]) {
            [self showAlertWithAppId:appId WithTitle:msg message:data sureBtn:@"现在升级" cancleBtn:nil];
        }
        else{
            [self showAlertWithAppId:appId WithTitle:msg message:data sureBtn:@"现在升级" cancleBtn:@"暂不升级"];
        }
    } failure:^(id error) {
        
    }];
}

- (void)showAlertWithAppId:(NSString *)appId WithTitle:(NSString *)title message:(NSString *)message sureBtn:(NSString *)sureString cancleBtn:(NSString *)cancelString{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (sureString) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:sureString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *itunsStr = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/us/id%@?mt=8",appId];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itunsStr]];
        }];
        [alertCtrl addAction:action];
    }
    if (cancelString) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:sureString style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertCtrl addAction:action];
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertCtrl animated:YES completion:nil];
}

#pragma mark --分享图片
- (void)activityShareWithImageUrlArray:(NSArray *)urlArray{
#if __has_include(<SDWebImage/SDWebImageManager.h>) || __has_include("SDWebImageManager.h")
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    [SVProgressHUD show];
    
    __block int i = 0;
    for (NSString *urlString  in urlArray) {
        if (urlString.length == 0) {
            continue;
        }
        SDWebImageManager *manager = [SDWebImageManager sharedManager] ;
        [manager downloadImageWithURL:[NSURL URLWithString:urlString] options:0 progress:^(NSInteger   receivedSize, NSInteger expectedSize) {
            // progression tracking code
        }  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,   BOOL finished, NSURL *imageURL) {
            if (image) {
                //防止太大分享失败,目前微信限制最大是32kb
                [UIImage scaleImage:image toKb:32];
                
                //本地路径
                NSString *str = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
                NSString *filePath = [NSString stringWithFormat:@"%@/huaji%d.jpg",str,i];
                //保存本地
                [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
                
                NSURL *fileURL = [NSURL fileURLWithPath:filePath];
                
                //把图片和路径传进来
                MJShareItem *item = [[MJShareItem alloc] initWithImage:image andfile:fileURL];
                [mArray addObject:item];
                i++;
                if (i == urlArray.count) {
                    [SVProgressHUD dismiss];
                    //里面initWithActivityItems  传的是item的数组  如果直接用图片数组的话 会经常出现 微信断开的错误
                    UIActivityViewController *activityView =[[UIActivityViewController alloc] initWithActivityItems:mArray
                                                                                              applicationActivities:nil];
                    
                    //需要忽略的分享
                    activityView.excludedActivityTypes = @[
                                                           UIActivityTypePrint,
                                                           UIActivityTypeCopyToPasteboard,
                                                           UIActivityTypeAssignToContact,
                                                           UIActivityTypeSaveToCameraRoll,
                                                           UIActivityTypeMail,
                                                           UIActivityTypePrint,
                                                           UIActivityTypeCopyToPasteboard,
                                                           UIActivityTypeAssignToContact,
                                                           UIActivityTypeSaveToCameraRoll,
                                                           UIActivityTypeAddToReadingList,
                                                           UIActivityTypePostToFlickr,
                                                           UIActivityTypeAirDrop
                                                           ];
                    
                    activityView.restorationIdentifier = @"activity";
                    [activityView setTitle:@"分享"];
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:activityView animated:TRUE completion:nil];
                }
            }
        }];
    }
#else
    NSAssert(NO, @"请导入SDWebImage后再使用网络图片功能");
#endif
}

#pragma mark -- 截屏并保存相册
- (void)captureImageFromViewAndSavePhotoWithCurrentView:(UIView *)view{
    [self savePhotoToMediaLibraryWithImage:[UIImage captureImageFromView:view]];
}

- (void)savePhotoToMediaLibraryWithImage:(UIImage *)image{
    ALAssetsLibrary * library = [ALAssetsLibrary new];
    NSData * data = UIImageJPEGRepresentation(image, 1.0);
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        //无权限
        [SVProgressHUD showInfoWithStatus:@"请先配置访问权限"];
        return;
    }
    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"保存失败"];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        }
    }];

}

#pragma mark --上传日志
- (void)upLoadLogInfo{
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    NSArray *logFilePaths = [fileLogger.logFileManager sortedLogFilePaths];
    for (NSString *string in logFilePaths) {
        if ([string containsString:@".log"]) {
            NSData *data = [NSData dataWithContentsOfFile:string];
            
            //配置请求体
            //设置服务器的URL
            NSString *url = [NSString stringWithFormat:@"https://rb0uqhjp.api.lncld.net/1.1/files/%@_%@_%@_%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
            
            AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
            session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json",@"application/x-www-form-urlencoded; charset=UTF-8", @"text/html", nil];//支持类型
            
            session.requestSerializer =  [AFHTTPRequestSerializer serializer];
            session.requestSerializer.timeoutInterval = 60;//请求超时
            session.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy; //缓存策略
            
            [session.requestSerializer setValue:@"DpvmCqLHqt4agjV6GPVS0wBM-gzGzoHsz" forHTTPHeaderField:@"X-LC-Id"];
            [session.requestSerializer setValue:@"qXf8aiXtL8kAlJUiyVqVxCfo" forHTTPHeaderField:@"X-LC-Key"];
            
            [session POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@_%@_%@_%@.txt",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion],getUserDefaults(CMJFDeviceToken) ? getUserDefaults(CMJFDeviceToken) : @"",getUserDefaults(CMJFAccount) ? getUserDefaults(CMJFAccount) : @""];
                [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"text/plain"];
                
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                NSLog(@"%f",1.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"上传成功");
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"上传失败");
            }];
        }
    }
}

#pragma mark--获取ssid信息
- (void)getSSIDInfo:(WXModuleKeepAliveCallback)callBack {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@ ---%@", ifnam,info,NSStringFromClass([info class]));
        if (info && [info count]) { break; }
    }
    if (callBack) {
        callBack(info,YES);
    }
}

#pragma mark -- 开始扫描
- (void)beginScanPerpheral:(WXModuleKeepAliveCallback)callBack{
    self.scanNum = 0;
    [self.bluetoothManage beginScanPerpheralSuccess:^(NSArray<CBPeripheral *> *peripherals, NSArray<NSNumber *> *rssis) {
        if (callBack && self.scanNum < scanMaxNumber) {
            [self.buletoothDataArray removeAllObjects];
            NSMutableArray *nameArray = [NSMutableArray array];
            for (CBPeripheral *per in peripherals) {
                [self.buletoothDataArray addObject:per];
                [nameArray addObject:per.name];
            }
            self.scanNum ++;
            if (_scanNum == scanMaxNumber - 1) {
                _scanNum = 0;
            }
            callBack([nameArray mj_JSONString], YES);
        }
    } failure:^(CBManagerState status) {
        if (callBack) {
            callBack(@"请先打开蓝牙", YES);
        }
    }];
}

#pragma mark -- 自动连接蓝牙
- (void)autoConnectLastPeripheral:(WXModuleKeepAliveCallback)callBack{
    [self.bluetoothManage autoConnectLastPeripheralCompletion:^(CBPeripheral *perpheral, NSError *error) {
        if (!error) {
            if (callBack) {
                callBack(perpheral.name, YES);
            }
        }else{
            if (callBack) {
                callBack(error.domain, YES);
            }
        }
    }];
}

#pragma mark -- 手动连接蓝牙
- (void)connectPeripheral:(NSInteger)index callBack:(WXModuleKeepAliveCallback)callBack{
    [self.bluetoothManage connectPeripheral:self.buletoothDataArray[index] completion:^(CBPeripheral *perpheral, NSError *error) {
        if (!error) {
            if (callBack) {
                callBack(@"1", YES);
            }
        }else{
            if (callBack) {
                callBack(@"0", YES);
            }
        }
    }];
}

#pragma mark -- 蓝牙打印
//蓝牙打印
- (void)bluetoothPrinte:(id)dict callBack:(WXModuleKeepAliveCallback)callBack{
    NSString *jsonString = dict;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:jsonData
                                                           options:NSJSONReadingMutableContainers
                                                             error:&err];
    if (self.bluetoothManage.stage != JWScanStageCharacteristics) {
        if (callBack) {
            callBack(@"2", YES);
        }
        return;
    }
    JWPrinter *printer = [[JWPrinter alloc] init];
    NSArray *statusStrArr = @[@"*取消*",@"*进行中*",@"*已完成*",@"*菜未上齐*",@"*菜已上齐*",@"*加菜*",@"*已结账*"];
    NSArray *payTypeArr = @[@"微信支付",@"支付宝支付",@"现金支付"];
    
    [printer appendSeperatorLine];
    [self smallPrintWith:[printer getFinalData]];
    printer = [[JWPrinter alloc] init];
    
    if ([params[@"singleType"] integerValue] == 0) {//普通单
        [printer appendText:params[@"shopName"] alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"订单号:" value:params[@"order_id"] ? params[@"order_id"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"桌号:" value:params[@"board_num"] ? params[@"board_num"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"交易时间:" value:[CMDateHelper getDateStringWithTimeIntervalString:params[@"createtime"] ? params[@"createtime"] : @"" withType:@"yyyy-MM-dd HH:mm:ss"]];
        [self smallPrintWith:[printer getFinalData]];
        
        if (params[@"goods_list"] && [params[@"goods_list"] count] > 0) {
            printer = [[JWPrinter alloc] init];
            [printer appendLeftText:@"商品名称" middleText:@"数量" rightText:@"金额" isTitle:NO];
            [self smallPrintWith:[printer getFinalData]];
            NSArray *goodList = params[@"goods_list"];
            
            for (NSDictionary *tempDict in goodList) {
                printer = [[JWPrinter alloc] init];
                [printer appendLeftText:tempDict[@"goods_name"] ? tempDict[@"goods_name"] : @"" middleText:tempDict[@"goods_number"] ? tempDict[@"goods_number"] : @"" rightText:tempDict[@"goods_price"] ? tempDict[@"goods_price"] : @"" isTitle:NO];
                [self smallPrintWith:[printer getFinalData]];
                printer = [[JWPrinter alloc] init];
                if (tempDict[@"property"] && [tempDict[@"property"] length] > 0) {
                    [printer appendText:[NSString stringWithFormat:@"(%@)",tempDict[@"property"] ? tempDict[@"property"] : @""] alignment:HLTextAlignmentLeft];
                }
                [self smallPrintWith:[printer getFinalData]];
            }
        }
        
        printer = [[JWPrinter alloc] init];
        [printer appendNewLine];
        [self smallPrintWith:[printer getFinalData]];
        
        if (params[@"generalSpecial"] && [params[@"generalSpecial"] length] > 0) {
            printer = [[JWPrinter alloc] init];
            [printer appendTitle:@"备注：" value:params[@"generalSpecial"] ? params[@"generalSpecial"] : @""];
            [self smallPrintWith:[printer getFinalData]];
        }
        
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"总金额:" value:params[@"total_amount"] ? params[@"total_amount"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"优惠金额:" value:params[@"preferential_price"] ? params[@"preferential_price"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"实付金额:" value:params[@"pay_amount"] ? params[@"pay_amount"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendNewLine];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendNewLine];
        [self smallPrintWith:[printer getFinalData]];
    }else if ([params[@"singleType"] integerValue] == 1){//加菜单
        [printer appendText:params[@"shopName"] alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendText:@"*加菜*" alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendText:@"--------------------------------" alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"订 单 号：" value:params[@"order_id"] ? params[@"order_id"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"桌    号：" value:params[@"board_num"] ? params[@"board_num"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"交易时间:" value:[CMDateHelper getDateStringWithTimeIntervalString:params[@"createtime"] ? params[@"createtime"] : @"" withType:@"yyyy-MM-dd HH:mm:ss"]];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        if (params[@"goods_list"] && [params[@"goods_list"] count] > 0) {
            printer = [[JWPrinter alloc] init];
            [printer appendLeftText:@"商品名称" middleText:@"数量" rightText:@"金额" isTitle:NO];
            [self smallPrintWith:[printer getFinalData]];
            NSArray *goodList = params[@"goods_list"];
            
            for (NSDictionary *tempDict in goodList) {
                printer = [[JWPrinter alloc] init];
                [printer appendLeftText:tempDict[@"goods_name"] ? tempDict[@"goods_name"] : @"" middleText:tempDict[@"goods_number"] ? tempDict[@"goods_number"] : @"" rightText:tempDict[@"goods_price"] ? tempDict[@"goods_price"] : @"" isTitle:NO];
                [self smallPrintWith:[printer getFinalData]];
                printer = [[JWPrinter alloc] init];
                if (tempDict[@"property"] && [tempDict[@"property"] length] > 0) {
                    [printer appendText:[NSString stringWithFormat:@"(%@)",tempDict[@"property"] ? tempDict[@"property"] : @""] alignment:HLTextAlignmentLeft];
                }
                [self smallPrintWith:[printer getFinalData]];
            }
        }
        
        printer = [[JWPrinter alloc] init];
        [printer appendNewLine];
        [self smallPrintWith:[printer getFinalData]];
        
        if (params[@"generalSpecial"] && [params[@"generalSpecial"] length] > 0) {
            printer = [[JWPrinter alloc] init];
            [printer appendTitle:@"备注：" value:params[@"generalSpecial"] ? params[@"generalSpecial"] : @""];
            [self smallPrintWith:[printer getFinalData]];
        }
        
        printer = [[JWPrinter alloc] init];
        [printer appendNewLine];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[JWPrinter alloc] init];
        [printer appendNewLine];
        [self smallPrintWith:[printer getFinalData]];
    }else if ([params[@"singleType"] integerValue] == 2){//结账单
        [printer appendText:params[@"shopName"] alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendText:statusStrArr[[params[@"order_status"] integerValue]] alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendText:@"*商户存根*" alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendText:@"--------------------------------" alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        
        [printer appendTitle:@"商户UID：" value:params[@"uid"] ? params[@"uid"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"订 单 号：" value:params[@"order_id"] ? params[@"order_id"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"交易时间:" value:[CMDateHelper getDateStringWithTimeIntervalString:params[@"createtime"] ? params[@"createtime"] : @"" withType:@"yyyy-MM-dd HH:mm:ss"]];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"桌    号：" value:params[@"board_num"] ? params[@"board_num"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"结账操作员：" value:params[@"account_name"] ? params[@"account_name"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"支付方式：" value:payTypeArr[[params[@"pay_type"] integerValue] - 1]];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"状    态：" value:@"交易成功"];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        
        [printer appendText:@"--------------------------------" alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"实收金额：" value:params[@"pay_amount"] ? params[@"pay_amount"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        
        [printer appendText:@"--------------------------------" alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendTitle:@"退菜金额：" value:params[@"retire_price"] ? params[@"retire_price"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendNewLine];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[JWPrinter alloc] init];
        [printer appendNewLine];
        [self smallPrintWith:[printer getFinalData]];
    }else{
        [printer appendText:@"--------------------------------" alignment:HLTextAlignmentCenter];
    }
    
}

- (void)smallPrintWith:(NSData *)data{
    [self.bluetoothManage sendPrintData:data completion:nil];
}

#pragma mark -- 二维码扫描
- (void)scanQR:(WXModuleKeepAliveCallback)callBack
{
    self.sanqrCallBack = callBack;
    [weexInstance.viewController.navigationController pushViewController:self.scanQRCtl animated:YES];
    [weexInstance.viewController.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark -- 链接到超盟商家
- (void)jumpTocmshop:(WXModuleKeepAliveCallback)callBack
{
    NSURL *url = [NSURL URLWithString:@"chaomengshangjia://"];
    
    //先判断是否能打开该url
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        //打开url
        [[UIApplication sharedApplication] openURL:url];
    }else {
        //给个提示或者做点别的事情
        NSLog(@"U四不四洒，没安装WXApp，怎么打开啊！");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确保您已经安装了超盟商+" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [weexInstance.viewController presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark -- 地图定位
- (void)pushToCtrlGetLocation:(WXModuleKeepAliveCallback)callBack{
    self.locationCallBack = callBack;
    [weexInstance.viewController.navigationController pushViewController:self.mapCtl animated:YES];
    [weexInstance.viewController.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark -- 拍照
- (void)photograph:(WXModuleKeepAliveCallback)callBack{
    self.imageCallBack = callBack;
    [self takePhoto];
}

- (void)takePhoto
{
    self.imagePickerCtl.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePickerCtl.delegate = self;
    [weexInstance.viewController presentViewController:self.imagePickerCtl animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *data = [image zec_compress];
    NSString *base64String = [CMJFEncriptionHelper encodeBase64WithData:data];
    
    self.imageCallBack ? self.imageCallBack(base64String, YES) : nil;
    
    [weexInstance.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [weexInstance.viewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -- 相册选取照片
- (void)selectPhotoFromPhotoAlbumOfNum:(NSInteger)num callBack:(WXModuleKeepAliveCallback)callBack
{
    self.imageCallBack = callBack;
    self.manager.configuration.saveSystemAblum = YES;
    if (num > 0) {
        self.manager.configuration.photoMaxNum = num;
    }
    __weak typeof(self) weakSelf = self;
    [weexInstance.viewController hx_presentAlbumListViewControllerWithManager:self.manager done:^(NSArray<HXPhotoModel *> *allList, NSArray<HXPhotoModel *> *photoList,NSArray<UIImage *> *imageList , NSArray<HXPhotoModel *> *videoList, BOOL original, HXAlbumListViewController *viewController) {
        if (photoList.count > 0) {
            [weakSelf.toolManager getSelectedImageList:photoList requestType:0 success:^(NSArray<UIImage *> *imageList) {
                NSMutableArray *base64StringArr = [NSMutableArray array];
                for (UIImage *image in imageList) {
                    NSData *data = [image zec_compress];
                    NSString *base64String = [CMJFEncriptionHelper encodeBase64WithData:data];
                    [base64StringArr addObject:base64String];
                }
                
                self.imageCallBack ? self.imageCallBack([base64StringArr mj_JSONString], YES) : nil;
                [weexInstance.viewController dismissViewControllerAnimated:YES completion:nil];
            } failed:^{
                
            }];
            NSSLog(@"%lu张图片",(unsigned long)photoList.count);
        }
    } cancel:^(HXAlbumListViewController *viewController) {
        NSSLog(@"取消了");
    }];
}

#pragma mark -- setter\getter
- (JWBluetoothManage *)bluetoothManage{
    if (!_bluetoothManage) {
        _bluetoothManage = [JWBluetoothManage sharedInstance];
    }
    return _bluetoothManage;
}

- (NSMutableArray *)buletoothDataArray{
    if (!_buletoothDataArray) {
        _buletoothDataArray = [NSMutableArray array];
    }
    return _buletoothDataArray;
}

- (NSSQRViewController *)scanQRCtl
{
    _scanQRCtl = [[NSSQRViewController alloc] init];
    __weak typeof(self)weakSelf = self;
    _scanQRCtl.scanCallBlk = ^(int code,NSString *msg) {
        weakSelf.sanqrCallBack ? weakSelf.sanqrCallBack(@{@"code": @(code),@"code_url": msg}, YES) : nil;
    };
    return _scanQRCtl;
}

- (MapViewCtl *)mapCtl
{
    if (!_mapCtl) {
        _mapCtl = [[MapViewCtl alloc] initWithNibName:NSStringFromClass([MapViewCtl class]) bundle:nil];
        __weak typeof(self)weakSelf = self;
        _mapCtl.locationAddressBlk = ^(double longitude, double latitude, NSString *address, NSString *detailAddress) {
            weakSelf.locationCallBack ? weakSelf.locationCallBack(@{@"longitude": @(longitude), @"latitude": @(latitude), @"address": address, @"detailAddress": detailAddress}, YES) : nil;
        };
    }
    return _mapCtl;
}

- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
    }
    return _manager;
}

- (HXDatePhotoToolManager *)toolManager {
    if (!_toolManager) {
        _toolManager = [[HXDatePhotoToolManager alloc] init];
    }
    return _toolManager;
}

- (UIImagePickerController *)imagePickerCtl
{
    if (!_imagePickerCtl) {
        _imagePickerCtl = [[UIImagePickerController alloc] init];
    }
    return _imagePickerCtl;
}

#pragma mark 获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    // 定义一个变量存放当前屏幕显示的viewcontroller
    UIViewController *result = nil;
    
    // 得到当前应用程序的主要窗口
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    // windowLevel是在 Z轴 方向上的窗口位置，默认值为UIWindowLevelNormal
    if (window.windowLevel != UIWindowLevelNormal)
    {
        // 获取应用程序所有的窗口
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            // 找到程序的默认窗口（正在显示的窗口）
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                // 将关键窗口赋值为默认窗口
                window = tmpWin;
                break;
            }
        }
    }
    
    // 获取窗口的当前显示视图
    UIView *frontView = [[window subviews] objectAtIndex:0];
    
    // 获取视图的下一个响应者，UIView视图调用这个方法的返回值为UIViewController或它的父视图
    id nextResponder = [frontView nextResponder];
    
    // 判断显示视图的下一个响应者是否为一个UIViewController的类对象
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    } else {
        result = window.rootViewController;
    }
    return result;
}

@end
