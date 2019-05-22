//
//  WeexNativeSupportManage.m
//  WeexDemo
//
//  Created by 超盟 on 2018/9/14.
//  Copyright © 2018年 wusx. All rights reserved.
//

#import "WeexNativeSupportManage.h"
#import "WeexBaseService.h"
#import "WeexShareItem.h"
#import "UIImage+WeexScaleImage.h"
#import <SVProgressHUD.h>
#if __has_include(<SDWebImage/SDWebImageManager.h>)
#import <SDWebImage/SDWebImageManager.h>
#elif __has_include("SDWebImageManager.h")
#import "SDWebImageManager.h"
#endif

//#if __has_include(<AlibcTradeSDK/AlibcTradeSDK.h>)
//#import <AlibcTradeSDK/AlibcTradeSDK.h>
//#elif __has_include("AlibcTradeSDK.h")
//#import "AlibcTradeSDK.h"
//#endif
#import "UIImage+WeexCapture.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "WeexNativeSupport.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <Photos/Photos.h>
#import "WeexBluetoothManage.h"
#import "WeexDateHelper.h"
#import <MJExtension.h>
#import "HXPhotoPicker.h"
#import "WeexEncriptionHelper.h"
#import "UIImage+WeexCompress.h"
#import "WeexLocationManage.h"
#import "WeexQRViewController.h"
#import "WeexPrinter.h"
#import <AFNetworking.h>
#define scanMaxNumber 3                //扫描蓝牙最大次数
@interface WeexNativeSupportManage ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,HXAlbumListViewControllerDelegate>

@property (strong, nonatomic) HXPhotoManager *manager;
@property (strong, nonatomic) HXDatePhotoToolManager *toolManager;

@property (nonatomic, copy) NSString *url;  //存储域名
@property (nonatomic, strong) WeexBluetoothManage * bluetoothManage;                                  //蓝牙管理类
@property (nonatomic, strong) NSMutableArray *buletoothDataArray;                                   //已扫描蓝牙设备集合
@property (nonatomic, assign) NSInteger scanNum;                                                    //当前已扫描次数
@property (nonatomic, strong) WeexQRViewController *scanQRCtl;
@property (nonatomic, strong) UIImagePickerController *imagePickerCtl;

@property (nonatomic, copy) WXModuleKeepAliveCallback imageCallBack;
@property (nonatomic, copy) WXModuleKeepAliveCallback locationCallBack;
@property (nonatomic, copy) WXModuleKeepAliveCallback sanqrCallBack;
@end

@implementation WeexNativeSupportManage
static WeexNativeSupportManage *manager = nil;
static AFHTTPSessionManager *netWorkManager;
- (AFHTTPSessionManager *)netWorkManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        netWorkManager = [[AFHTTPSessionManager alloc] init];
        netWorkManager.requestSerializer =  [AFHTTPRequestSerializer serializer];
        netWorkManager.requestSerializer.timeoutInterval = 30;//请求超时
        //      manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy; //缓存策略
        netWorkManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];//支持类型
        
    });
    return netWorkManager;
}
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
    [WeexBaseService getAppVersionWithUrl:_url isShowLatestVersionTips:isShow success:^(id data, id msg, id is_force) {
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
        UIAlertAction *action = [UIAlertAction actionWithTitle:cancelString style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
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
                WeexShareItem *item = [[WeexShareItem alloc] initWithImage:image andfile:fileURL];
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
        [self.bluetoothManage stopScanPeripheral];
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
            [self.bluetoothManage stopScanPeripheral];
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
    WeexPrinter *printer = [[WeexPrinter alloc] init];
    NSArray *statusStrArr = @[@"*取消*",@"*进行中*",@"*已完成*",@"*菜未上齐*",@"*菜已上齐*",@"*加菜*",@"*已结账*"];
    NSArray *payTypeArr = @[@"微信支付",@"支付宝支付",@"现金支付"];
    
    if ([params[@"singleType"] integerValue] == 0) {//普通单
        printer = [[WeexPrinter alloc] init];
        [printer appendText:params[@"shopName"] alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleBig];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendSeperatorLine];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendText:[NSString stringWithFormat:@"桌号： %@",params[@"board_num"]] alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleBig];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[WeexPrinter alloc] init];
        [printer appendSeperatorLine];
        [self smallPrintWith:[printer getFinalData]];
        
        if (params[@"serial_num"]) {
            printer = [[WeexPrinter alloc] init];
            [printer appendText:[NSString stringWithFormat:@"流水号 %@",params[@"serial_num"]] alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleBig];
            [self smallPrintWith:[printer getFinalData]];
            printer = [[WeexPrinter alloc] init];
            [printer appendSeperatorLine];
            [self smallPrintWith:[printer getFinalData]];
        }
        
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"订单号" value:params[@"order_id"] ? params[@"order_id"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"下单时间" value:[WeexDateHelper getDateStringWithTimeIntervalString:params[@"createtime"] ? params[@"createtime"] : @"" withType:@"yyyy-MM-dd HH:mm:ss"]];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"桌号" value:params[@"board_num"] ? params[@"board_num"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"下单员" value:params[@"account_name"] ? params[@"account_name"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendSeperatorLine];
        [self smallPrintWith:[printer getFinalData]];
        
        
        if (params[@"goods_list"] && [params[@"goods_list"] count] > 0) {
            printer = [[WeexPrinter alloc] init];
            [printer appendLeftText:@"商品名称" middleText:@"数量" rightText:@"小计" isTitle:YES];
            [self smallPrintWith:[printer getFinalData]];
            
            printer = [[WeexPrinter alloc] init];
            [printer appendSeperatorLine];
            [self smallPrintWith:[printer getFinalData]];
            
            NSArray *goodList = params[@"goods_list"];
            
            for (NSDictionary *tempDict in goodList) {
                printer = [[WeexPrinter alloc] init];
                [printer appendLeftText:tempDict[@"goods_name"] ? tempDict[@"goods_name"] : @"" middleText:tempDict[@"goods_number"] ? tempDict[@"goods_number"] : @"" rightText:tempDict[@"goods_price"] ? tempDict[@"goods_price"] : @"" isTitle:NO];
                [self smallPrintWith:[printer getFinalData]];
                
                if ([tempDict[@"property"] length] > 0 || [tempDict[@"total_price"] length] > 0){
                    
                    printer = [[WeexPrinter alloc] init];
                    [printer appendLeftText:tempDict[@"property"] ? tempDict[@"property"] : @"" middleText:tempDict[@"goods_unit_num"] ? tempDict[@"goods_unit_num"] : @"" rightText:tempDict[@"total_price"] ? tempDict[@"total_price"] : @"" isTitle:NO];
                    [self smallPrintWith:[printer getFinalData]];
                }
                
                printer = [[WeexPrinter alloc] init];
                [printer appendSeperatorLine];
                [self smallPrintWith:[printer getFinalData]];
            }
        }
        
        if (params[@"generalSpecial"] && [params[@"generalSpecial"] length] > 0) {
            printer = [[WeexPrinter alloc] init];
            [printer appendTitle:@"备注：" value:params[@"generalSpecial"] ? params[@"generalSpecial"] : @""];
            [self smallPrintWith:[printer getFinalData]];
        }
        
        if (params[@"discount"] && [params[@"discount"] length] > 0) {
            printer = [[WeexPrinter alloc] init];
            [printer appendTitle:@"折扣：" value:params[@"discount"] ? params[@"discount"] : @""];
            [self smallPrintWith:[printer getFinalData]];
        }
        
        printer = [[WeexPrinter alloc] init];
        [printer appendLeftText:@"总数量" middleText:@"" rightText:params[@"total_num"] isTitle:NO];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"应付:" value:params[@"total_amount"] ? params[@"total_amount"] : @"" valueOffset:1  fontSize:HLFontSizeTitleBig];
        [self smallPrintWith:[printer getFinalData]];
        
        if (params[@"preferential_price"] && [params[@"preferential_price"] floatValue] != 0) {
            printer = [[WeexPrinter alloc] init];
            [printer appendTitle:@"优惠:" value:params[@"preferential_price"] ? params[@"preferential_price"] : @"" valueOffset:1  fontSize:HLFontSizeTitleBig];
            [self smallPrintWith:[printer getFinalData]];
        }
        
        
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"待付金额:" value:params[@"pay_amount"] ? params[@"pay_amount"] : @"" valueOffset:1  fontSize:HLFontSizeTitleBig];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendSeperatorLine];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendText:@"欢迎光临" alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendNewLine];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendNewLine];
        [self smallPrintWith:[printer getFinalData]];
        
    }else if ([params[@"singleType"] integerValue] == 1){//加菜单
        [printer appendText:params[@"shopName"] alignment:HLTextAlignmentCenter  fontSize:HLFontSizeTitleBig];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendText:@"*加菜*" alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        
        
        if (params[@"serial_num"]) {
            printer = [[WeexPrinter alloc] init];
            [printer appendSeperatorLine];
            [self smallPrintWith:[printer getFinalData]];
            
            printer = [[WeexPrinter alloc] init];
            [printer appendText:[NSString stringWithFormat:@"流水号 %@",params[@"serial_num"]] alignment:HLTextAlignmentCenter  fontSize:HLFontSizeTitleBig];
            [self smallPrintWith:[printer getFinalData]];
        }
        
        printer = [[WeexPrinter alloc] init];
        [printer appendSeperatorLine];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendText:[NSString stringWithFormat:@"桌号： %@",params[@"board_num"]] alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleBig];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[WeexPrinter alloc] init];
        [printer appendSeperatorLine];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"订 单 号：" value:params[@"order_id"] ? params[@"order_id"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"下单时间:" value:[WeexDateHelper getDateStringWithTimeIntervalString:params[@"createtime"] ? params[@"createtime"] : @"" withType:@"yyyy-MM-dd HH:mm:ss"]];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"下单员：" value:params[@"account_name"] ? params[@"account_name"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendSeperatorLine];
        [self smallPrintWith:[printer getFinalData]];
        
        if (params[@"goods_list"] && [params[@"goods_list"] count] > 0) {
            printer = [[WeexPrinter alloc] init];
            [printer appendLeftText:@"商品名称" middleText:@"数量" rightText:@"小计" isTitle:YES];
            [self smallPrintWith:[printer getFinalData]];
            
            
            printer = [[WeexPrinter alloc] init];
            [printer appendSeperatorLine];
            [self smallPrintWith:[printer getFinalData]];
            NSArray *goodList = params[@"goods_list"];
            
            for (NSDictionary *tempDict in goodList) {
                printer = [[WeexPrinter alloc] init];
                [printer appendLeftText:tempDict[@"goods_name"] ? tempDict[@"goods_name"] : @"" middleText:tempDict[@"goods_number"] ? tempDict[@"goods_number"] : @"" rightText:tempDict[@"goods_price"] ? tempDict[@"goods_price"] : @"" isTitle:NO];
                [self smallPrintWith:[printer getFinalData]];
                
                if ([tempDict[@"property"] length] > 0 || [tempDict[@"total_price"] length] > 0){
                    printer = [[WeexPrinter alloc] init];
                    [printer appendLeftText:tempDict[@"property"] ? tempDict[@"property"] : @"" middleText:tempDict[@"goods_unit_num"] ? tempDict[@"goods_unit_num"] : @"" rightText:tempDict[@"total_price"] ? tempDict[@"total_price"] : @"" isTitle:NO];
                    [self smallPrintWith:[printer getFinalData]];
                }
                
                printer = [[WeexPrinter alloc] init];
                [printer appendSeperatorLine];
                [self smallPrintWith:[printer getFinalData]];
            }
        }
        
        if (params[@"generalSpecial"] && [params[@"generalSpecial"] length] > 0) {
            printer = [[WeexPrinter alloc] init];
            [printer appendTitle:@"备注：" value:params[@"generalSpecial"] ? params[@"generalSpecial"] : @""];
            [self smallPrintWith:[printer getFinalData]];
        }
        
        if (params[@"discount"] && [params[@"discount"] length] > 0) {
            printer = [[WeexPrinter alloc] init];
            [printer appendTitle:@"折扣：" value:params[@"discount"] ? params[@"discount"] : @""];
            [self smallPrintWith:[printer getFinalData]];
        }
        
        printer = [[WeexPrinter alloc] init];
        [printer appendLeftText:@"总数量" middleText:@"" rightText:params[@"total_num"] isTitle:NO];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendSeperatorLine];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendText:@"欢迎光临" alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendNewLine];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendSeperatorLine];
        [self smallPrintWith:[printer getFinalData]];
        
    }else if ([params[@"singleType"] integerValue] == 2){//结账单
        [printer appendText:params[@"shopName"] alignment:HLTextAlignmentCenter  fontSize:HLFontSizeTitleBig];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendText:statusStrArr[[params[@"order_status"] integerValue]] alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendText:[NSString stringWithFormat:@"桌号： %@",params[@"board_num"]] alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleBig];
        [self smallPrintWith:[printer getFinalData]];
        printer = [[WeexPrinter alloc] init];
        [printer appendSeperatorLine];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendText:@"*商户存根*" alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        
        if (params[@"serial_num"]) {
            printer = [[WeexPrinter alloc] init];
            [printer appendSeperatorLine];
            [self smallPrintWith:[printer getFinalData]];
            
            printer = [[WeexPrinter alloc] init];
            [printer appendText:[NSString stringWithFormat:@"流水号 %@",params[@"serial_num"]] alignment:HLTextAlignmentCenter fontSize:HLFontSizeTitleBig];
            [self smallPrintWith:[printer getFinalData]];
            
        }
        
        printer = [[WeexPrinter alloc] init];
        [printer appendSeperatorLine];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"订 单 号：" value:params[@"order_id"] ? params[@"order_id"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        if (params[@"discount"] && [params[@"discount"] length] > 0) {
            printer = [[WeexPrinter alloc] init];
            [printer appendTitle:@"折扣：" value:params[@"discount"] ? params[@"discount"] : @""];
            [self smallPrintWith:[printer getFinalData]];
        }
        
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"收银员：" value:params[@"account_name"] ? params[@"account_name"] : @""];
        [self smallPrintWith:[printer getFinalData]];
        
        if (params[@"goods_list"] && [params[@"goods_list"] count] > 0) {
            printer = [[WeexPrinter alloc] init];
            [printer appendLeftText:@"商品名称" middleText:@"数量" rightText:@"小计" isTitle:YES];
            [self smallPrintWith:[printer getFinalData]];
            
            
            printer = [[WeexPrinter alloc] init];
            [printer appendSeperatorLine];
            [self smallPrintWith:[printer getFinalData]];
            NSArray *goodList = params[@"goods_list"];
            
            for (NSDictionary *tempDict in goodList) {
                printer = [[WeexPrinter alloc] init];
                [printer appendLeftText:tempDict[@"goods_name"] ? tempDict[@"goods_name"] : @"" middleText:tempDict[@"goods_number"] ? tempDict[@"goods_number"] : @"" rightText:tempDict[@"goods_price"] ? tempDict[@"goods_price"] : @"" isTitle:NO];
                [self smallPrintWith:[printer getFinalData]];
                
                if ([tempDict[@"property"] length] > 0 || [tempDict[@"total_price"] length] > 0){
                    printer = [[WeexPrinter alloc] init];
                    [printer appendLeftText:tempDict[@"property"] ? tempDict[@"property"] : @"" middleText:tempDict[@"goods_unit_num"] ? tempDict[@"goods_unit_num"] : @"" rightText:tempDict[@"total_price"] ? tempDict[@"total_price"] : @"" isTitle:NO];
                    [self smallPrintWith:[printer getFinalData]];
                }
                
                printer = [[WeexPrinter alloc] init];
                [printer appendSeperatorLine];
                [self smallPrintWith:[printer getFinalData]];
            }
        }
        
        if (params[@"generalSpecial"] && [params[@"generalSpecial"] length] > 0) {
            printer = [[WeexPrinter alloc] init];
            [printer appendTitle:@"备注：" value:params[@"generalSpecial"] ? params[@"generalSpecial"] : @""];
            [self smallPrintWith:[printer getFinalData]];
        }
        
        if (params[@"discount"] && [params[@"discount"] length] > 0) {
            printer = [[WeexPrinter alloc] init];
            [printer appendTitle:@"折扣：" value:params[@"discount"] ? params[@"discount"] : @""];
            [self smallPrintWith:[printer getFinalData]];
        }
        
        printer = [[WeexPrinter alloc] init];
        [printer appendLeftText:@"总数量" middleText:@"" rightText:params[@"total_num"] isTitle:NO];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"支付方式：" value:payTypeArr[[params[@"pay_type"] integerValue] - 1]];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"状    态：" value:@"交易成功"];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendTitle:@"应付:" value:params[@"total_amount"] ? params[@"total_amount"] : @"" valueOffset:1 fontSize:HLFontSizeTitleBig];
        [self smallPrintWith:[printer getFinalData]];
        
        if (params[@"preferential_price"] && [params[@"preferential_price"] floatValue] != 0) {
            printer = [[WeexPrinter alloc] init];
            [printer appendTitle:@"优惠:" value:params[@"preferential_price"] ? params[@"preferential_price"] : @"" valueOffset:1 fontSize:HLFontSizeTitleBig];
            [self smallPrintWith:[printer getFinalData]];
            printer = [[WeexPrinter alloc] init];
        }
        
        [printer appendTitle:@"实付金额:" value:params[@"pay_amount"] ? params[@"pay_amount"] : @"" valueOffset:1 fontSize:HLFontSizeTitleBig];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendSeperatorLine];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendText:@"欢迎下次光临" alignment:HLTextAlignmentCenter];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendNewLine];
        [self smallPrintWith:[printer getFinalData]];
        
        printer = [[WeexPrinter alloc] init];
        [printer appendSeperatorLine];
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
    [[[UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers firstObject] presentViewController:self.scanQRCtl animated:YES completion:nil];
    
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
        if (callBack) {
            callBack(@"fail",YES);
        }
    }
}

- (void)openThirdApplication:(NSString *)urlSchemes callBack:(WXModuleKeepAliveCallback)callBack {
    NSURL *url = [NSURL URLWithString:urlSchemes];
    
    //先判断是否能打开该url
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        //打开url
        [[UIApplication sharedApplication] openURL:url];
    }else {
        if (callBack) {
            callBack(@"fail",YES);
        }
    }
}

#pragma mark -- 拍照
- (void)photograph:(WXModuleKeepAliveCallback)callBack{
    self.imageCallBack = callBack;
    self.manager.configuration.singleJumpEdit = YES;
    self.manager.configuration.singleSelected = YES;
    [self checkAuthorizationStatus];
}
//新api
- (void)photographWithParameter:(NSDictionary *)parame callBack:(WXModuleKeepAliveCallback)callBack{
    self.imageCallBack = callBack;
    self.manager.configuration.singleSelected = YES;
    self.manager.configuration.singleJumpEdit = [parame[@"edit"] boolValue];            //是否可以裁剪
    if([parame[@"edit"] boolValue]){
        self.manager.configuration.movableCropBox = [parame[@"movableCropBox"] boolValue];  //是否可移动的裁剪框
        self.manager.configuration.movableCropBoxEditSize = [parame[@"movableCropBoxEditSize"] boolValue];;  //可移动的裁剪框是否可以编辑大小
        self.manager.configuration.movableCropBoxCustomRatio = CGPointMake([parame[@"movableCropBoxCustomRatio"] floatValue], 1);
    }
    [self checkAuthorizationStatus];
}

- (void)takePhoto {
    UIViewController *topRootViewController = [[UIApplication  sharedApplication] keyWindow].rootViewController;
    
    // 在这里加一个这个样式的循环
    while (topRootViewController.presentedViewController)
    {
        // 这里固定写法
        topRootViewController = topRootViewController.presentedViewController;
    }
    
    [topRootViewController hx_presentCustomCameraViewControllerWithManager:self.manager done:^(HXPhotoModel *model, HXCustomCameraViewController *viewController) {
        [self.toolManager getSelectedImageList:@[model] success:^(NSArray<UIImage *> *imageList) {
            UIImage *image = [imageList firstObject];
            NSString *base64String = [WeexEncriptionHelper encodeBase64WithData:[self compressImageQuality:image toByte:102400]];
            self.imageCallBack ? self.imageCallBack(base64String, YES) : nil;
        } failed:^{
            
        }];
    } cancel:^(HXCustomCameraViewController *viewController) {
        
    }];
}

- (UIViewController *)topRootViewController {
    UIViewController *viewController = [[UIApplication  sharedApplication] keyWindow].rootViewController;
    
    // 在这里加一个这个样式的循环
    while (viewController.presentedViewController)
    {
        // 这里固定写法
        viewController = viewController.presentedViewController;
    }
    return viewController;
}

#pragma mark - 检测摄像头权限
-(void)checkAuthorizationStatus {
    
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined:[self showAuthorizationNotDetermined]; break;// 用户尚未决定授权与否，那就请求授权
        case AVAuthorizationStatusAuthorized:[self showAuthorizationAuthorized]; break;// 用户已授权，那就立即使用
        case AVAuthorizationStatusDenied:[self showAuthorizationDenied]; break;// 用户明确地拒绝授权，那就展示提示
        case AVAuthorizationStatusRestricted:[self showAuthorizationRestricted]; break;// 无法访问相机设备，那就展示提示
    }
}

#pragma mark - 相机使用权限处理
#pragma mark 用户还未决定是否授权使用相机
-(void)showAuthorizationNotDetermined {
    __weak typeof(self) weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            [weakSelf takePhoto];
        } else {
            [weakSelf showAuthorizationDenied];
        }
    }];
}
#pragma mark 被授权使用相机
- (void)showAuthorizationAuthorized {
    [self takePhoto];
}
#pragma mark 未被授权使用相机
-(void)showAuthorizationDenied {
    //无权限
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法访问相机" message:@"请在设置-隐私-相机中允许访问相机" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settings = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
            
            if (@available(iOS 10.0, *)) {
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }
        
    }];
    
    [alert addAction:cancel];
    [alert addAction:settings];
    
    [[self topRootViewController] presentViewController:alert animated:YES completion:nil];
}
#pragma mark 使用相机设备受限
-(void)showAuthorizationRestricted {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法访问相机" message:@"请检查您的手机硬件或设置" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [[self topRootViewController] presentViewController:alert animated:YES completion:nil];
}


#pragma mark -- 相册选取照片
- (void)selectPhotoFromPhotoAlbumOfNum:(NSInteger)num callBack:(WXModuleKeepAliveCallback)callBack
{
    self.manager.configuration.singleJumpEdit = NO;
    self.imageCallBack = callBack;
    if (num > 1) {
        self.manager.configuration.photoMaxNum = num;
    }else{
        _manager.configuration.singleSelected = YES;
        _manager.configuration.singleJumpEdit = YES;
    }
    [self selectPhoto];
}

//建议使用新的api
- (void)selectPhotoFromPhotoAlbum:(NSDictionary *)params callBack:(WXModuleKeepAliveCallback)callBack {
    self.manager.configuration.singleJumpEdit = NO;
    self.imageCallBack = callBack;
    if([params[@"num"] integerValue] > 1){
        self.manager.configuration.photoMaxNum = [params[@"num"] integerValue];
    }else{
        self.manager.configuration.singleSelected = YES;
        if([params[@"edit"] boolValue]){
            self.manager.configuration.singleJumpEdit = [params[@"edit"] boolValue];            //是否可以裁剪
            self.manager.configuration.movableCropBox = [params[@"movableCropBox"] boolValue];  //是否可移动的裁剪框
            self.manager.configuration.movableCropBoxEditSize = [params[@"movableCropBoxEditSize"] boolValue];  //可移动的裁剪框是否可以编辑大小
            self.manager.configuration.movableCropBoxCustomRatio = CGPointMake([params[@"movableCropBoxCustomRatio"] floatValue], 1);  // 可移动裁剪框的比例 (w,h)
        }
    }
    [self selectPhoto];
}

- (void)selectPhoto{
    UIViewController *topRootViewController = [[UIApplication  sharedApplication] keyWindow].rootViewController;
    
    // 在这里加一个这个样式的循环
    while (topRootViewController.presentedViewController)
    {
        // 这里固定写法
        topRootViewController = topRootViewController.presentedViewController;
    }
    [topRootViewController hx_presentAlbumListViewControllerWithManager:self.manager done:^(NSArray<HXPhotoModel *> *allList, NSArray<HXPhotoModel *> *photoList, NSArray<HXPhotoModel *> *videoList, NSArray<UIImage *> *imageList, BOOL original, HXAlbumListViewController *viewController) {
        if (photoList.count > 0) {
            [self.toolManager getSelectedImageList:photoList requestType:0 success:^(NSArray<UIImage *> *imageList) {
                NSMutableArray *base64StringArr = [NSMutableArray array];
                for (UIImage *image in imageList) {
                    
                    NSString *base64String = [WeexEncriptionHelper encodeBase64WithData:[self compressImageQuality:image toByte:102400]];
                    [base64StringArr addObject:base64String];
                }
                
                self.imageCallBack ? self.imageCallBack([base64StringArr mj_JSONString], YES) : nil;
                [viewController dismissViewControllerAnimated:YES completion:nil];
            } failed:^{
                
            }];
            NSSLog(@"%lu张图片",(unsigned long)photoList.count);
        }
    } cancel:^(HXAlbumListViewController *viewController) {
        
    }];
}

- (NSData *)compressImageQuality:(UIImage *)image toByte:(NSInteger)maxLength {
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    //UIImage *resultImage = [UIImage imageWithData:data];
    return data;
}

#pragma mark -- delegate


#pragma mark -- setter\getter
- (WeexBluetoothManage *)bluetoothManage{
    if (!_bluetoothManage) {
        _bluetoothManage = [WeexBluetoothManage sharedInstance];
    }
    return _bluetoothManage;
}

- (NSMutableArray *)buletoothDataArray{
    if (!_buletoothDataArray) {
        _buletoothDataArray = [NSMutableArray array];
    }
    return _buletoothDataArray;
}

- (WeexQRViewController *)scanQRCtl
{
    NSString* bundlePath = [[NSBundle mainBundle]pathForResource: @"HXPhotoPicker"ofType:@"bundle"];
    
    NSBundle *resourceBundle =[NSBundle bundleWithPath:bundlePath];
    
    _scanQRCtl = [[WeexQRViewController alloc] initWithNibName:@"WeexQRViewController" bundle:resourceBundle];
    __weak typeof(self)weakSelf = self;
    _scanQRCtl.scanCallBack = ^(int code, NSString *msg) {
        weakSelf.sanqrCallBack ? weakSelf.sanqrCallBack(@{@"code": @(code),@"code_url": msg}, YES) : nil;
    };
    
    return _scanQRCtl;
}



- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.saveSystemAblum = NO;
        _manager.configuration.openCamera = NO;
        _manager.configuration.themeColor = [UIColor blackColor];
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


@end
