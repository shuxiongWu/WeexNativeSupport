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
#import "MapViewCtl.h"
#import "CMJFEncriptionHelper.h"
#import "UIImage+XJSCompress.h"
#import "HXPhotoPicker.h"
#import "MYWXThreadSafeMutableDictionary.h"
#import "JWBluetoothManage.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <MJExtension.h>
#import "WeexNativeSupport.h"
#import "CMDateHelper.h"
#import "WeexNativeSupportManage.h"
static NSString * const WXStorageDirectory            = @"wxstorage";
static NSString * const WXStorageFileName             = @"wxstorage.plist";
#define scanMaxNumber 3                //扫描蓝牙最大次数
@interface WXCustomEventModule ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,HXAlbumListViewControllerDelegate>
@property (nonatomic, strong) MapViewCtl *mapCtl;
@property (nonatomic, strong) NSSQRViewController *scanQRCtl;
@property (nonatomic, copy) WXModuleKeepAliveCallback imageCallBack;
@property (nonatomic, copy) WXModuleKeepAliveCallback locationCallBack;
@property (nonatomic, strong) UIImagePickerController *imagePickerCtl;
@property (nonatomic, copy) WXModuleKeepAliveCallback sanqrCallBack;
@property (strong, nonatomic) HXPhotoManager *manager;
@property (strong, nonatomic) HXDatePhotoToolManager *toolManager;

//蓝牙相关
@property (nonatomic, strong) JWBluetoothManage * bluetoothManage;                                  //管理类
@property (nonatomic, copy) WXModuleKeepAliveCallback beginScanPerpheralHandler;                    //扫描周边蓝牙列表回调
@property (nonatomic, copy) WXModuleKeepAliveCallback autoConnectLastPeripheralHandler;             //自动连接的回调
@property (nonatomic, copy) WXModuleKeepAliveCallback connectSuccessHandler;                        //手动连接的回调
@property (nonatomic, copy) WXModuleKeepAliveCallback SSIDHandler;                                  //Wifi SSID
    @property (nonatomic, copy) WXModuleKeepAliveCallback getVersionHandler;                            //版本号回调
@property (nonatomic, copy) WXModuleKeepAliveCallback bluetoothPrinteStatusHandler;                 //打印状态回调

@property (nonatomic, strong) NSMutableArray *buletoothDataArray;                                   //已扫描蓝牙设备集合
@property (nonatomic, assign) NSInteger scanNum;                                                    //当前已扫描次数

@end

@implementation WXCustomEventModule
@synthesize weexInstance;
WX_EXPORT_METHOD(@selector(call:))
WX_EXPORT_METHOD(@selector(addImgs:))
WX_EXPORT_METHOD(@selector(mapName:))
WX_EXPORT_METHOD(@selector(scanQR:))
WX_EXPORT_METHOD(@selector(addphoto:callBack:))
WX_EXPORT_METHOD(@selector(jumptocmshop:))
WX_EXPORT_METHOD(@selector(deviceToken:))// 添加获取方法给js
WX_EXPORT_METHOD(@selector(scanQR2:))

////蓝牙管理类相关api
WX_EXPORT_METHOD(@selector(beginScanPerpheral:))            //扫描
WX_EXPORT_METHOD(@selector(autoConnectLastPeripheral:))     //自动连接
WX_EXPORT_METHOD(@selector(connectPeripheral:callBack:))    //手动连接
WX_EXPORT_METHOD(@selector(bluetoothPrinte:callBack:))      //蓝牙打印

//WIFI相关api
WX_EXPORT_METHOD(@selector(getSSIDInfo:))            //获取SSID

//日志上传
WX_EXPORT_METHOD(@selector(upLoadLogInfo:))          //上传日志
WX_EXPORT_METHOD(@selector(printeLogInfoWithLog:callBack:))          //打印日志
    
//版本更新
WX_EXPORT_METHOD(@selector(checkVersion:callBack:))          //去商店更新
WX_EXPORT_METHOD(@selector(getVersion:))                     //获取版本号

//打开淘宝领优惠券
WX_EXPORT_METHOD(@selector(getCoupon:callBack:))      //打开淘宝

//分享
WX_EXPORT_METHOD(@selector(activityShareWithImageUrlArray:callBack:))      //纯图片分享

+ (void)load{
    [WXSDKEngine registerModule:@"event" withClass:[WXCustomEventModule class]];
}

- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        //_manager.configuration.singleSelected = YES;
        _manager.configuration.albumListTableView = ^(UITableView *tableView) {
            //            NSSLog(@"%@",tableView);
        };
        
        //_manager.configuration.singleJumpEdit = YES;
        //        _manager.configuration.movableCropBox = YES;
        //        _manager.configuration.movableCropBoxEditSize = YES;
        //        _manager.configuration.movableCropBoxCustomRatio = CGPointMake(1, 1);
    }
    return _manager;
}

- (HXDatePhotoToolManager *)toolManager {
    if (!_toolManager) {
        _toolManager = [[HXDatePhotoToolManager alloc] init];
    }
    return _toolManager;
}


-(void)call:(NSString*)num{
    //NSString *phone = CMJFPhoneNum;
    NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"tel:%@",num];
    UIWebView *callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
//    [self.view addSubview:callWebview];
    [[self getCurrentVC].view addSubview:callWebview];
}

- (void)addImgs:(WXModuleKeepAliveCallback)callBack
{
    [self showCamera];
    self.imageCallBack = callBack;
}

- (void)mapName:(WXModuleKeepAliveCallback)callBack
{
    [self shoMap];
    self.locationCallBack = callBack;
}

- (void)scanQR:(WXModuleKeepAliveCallback)callBack
{
    self.sanqrCallBack = callBack;
    [self showScan];
    
}

- (void)scanQR2:(WXModuleKeepAliveCallback)callBack
{
    self.sanqrCallBack = callBack;
    [self showScan];
    
}

- (void)jumptocmshop:(WXModuleKeepAliveCallback)callBack
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

        [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
    }
}

- (void)addphoto:(NSInteger)num callBack:(WXModuleKeepAliveCallback)callBack
{
    self.imageCallBack = callBack;
    self.manager.configuration.saveSystemAblum = YES;
    if (num > 0) {
        self.manager.configuration.photoMaxNum = num;
        if (num == 1) {//单选时设置裁剪
            _manager.configuration.singleSelected = YES;
            _manager.configuration.singleJumpEdit = YES;
            _manager.configuration.movableCropBox = YES;
            _manager.configuration.movableCropBoxEditSize = YES;
            _manager.configuration.movableCropBoxCustomRatio = CGPointMake(1, 1);
        }
    }
    __weak typeof(self) weakSelf = self;
    [[self getCurrentVC] hx_presentAlbumListViewControllerWithManager:self.manager done:^(NSArray<HXPhotoModel *> *allList, NSArray<HXPhotoModel *> *photoList,NSArray<UIImage *> *imageList , NSArray<HXPhotoModel *> *videoList, BOOL original, HXAlbumListViewController *viewController) {
        if (photoList.count > 0) {
            
            [weakSelf.toolManager getSelectedImageList:photoList requestType:0 success:^(NSArray<UIImage *> *imageList) {
             
                UIImage *image = imageList.firstObject;
                NSData *data = [image zec_compress];
                NSString *base64String = [CMJFEncriptionHelper encodeBase64WithData:data];
                
                self.imageCallBack ? self.imageCallBack(base64String, YES) : nil;
                
                [weexInstance.viewController dismissViewControllerAnimated:YES completion:nil];
            } failed:^{
               
            }];
            NSSLog(@"%lu张图片",(unsigned long)photoList.count);
        }
    } cancel:^(HXAlbumListViewController *viewController) {
        NSSLog(@"取消了");
    }];
}

- (void)deviceToken:(WXModuleKeepAliveCallback)callBack
{
//    NSString *deviceToken = getUserDefaults(CMJFDeviceToken);
//    NSSLog(@"deviceToken IS %@",deviceToken);
    callBack(getUserDefaults(CMJFDeviceToken),YES);
}

- (void)albumListViewController:(HXAlbumListViewController *)albumListViewController didDoneAllList:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photoList videos:(NSArray<HXPhotoModel *> *)videoList original:(BOOL)original {
    if (photoList.count > 0) {

        NSSLog(@"%lu张图片",(unsigned long)photoList.count);
    }else if (videoList.count > 0) {
        
        [self.toolManager getSelectedImageList:allList success:^(NSArray<UIImage *> *imageList) {
           
        } failed:^{
            
        }];
        
       
    }
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


// MARK: Camera
// MARK: Camera and Photo Library
- (UIImagePickerController *)imagePickerCtl
{
    if (!_imagePickerCtl) {
        _imagePickerCtl = [[UIImagePickerController alloc] init];
    }
    return _imagePickerCtl;
}

- (void)photoLibrary
{
    self.imagePickerCtl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [weexInstance.viewController presentViewController:self.imagePickerCtl animated:YES completion:nil];
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

- (void)showCamera {
    [self takePhoto];
    //    [self shoMap];
}

// MARK: Map
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

- (void)shoMap
{
    [weexInstance.viewController.navigationController pushViewController:self.mapCtl animated:YES];
    [weexInstance.viewController.navigationController setNavigationBarHidden:NO animated:YES];
}



- (NSSQRViewController *)scanQRCtl
{
//    if (!_scanQRCtl) {
        _scanQRCtl = [[NSSQRViewController alloc] init];
        __weak typeof(self)weakSelf = self;
        _scanQRCtl.scanCallBlk = ^(int code,NSString *msg) {
            weakSelf.sanqrCallBack ? weakSelf.sanqrCallBack(@{@"code": @(code),@"code_url": msg}, YES) : nil;
        };
//    }
    return _scanQRCtl;
}

- (void)showScan
{
    [weexInstance.viewController.navigationController pushViewController:self.scanQRCtl animated:YES];
    [weexInstance.viewController.navigationController setNavigationBarHidden:NO animated:YES];
}

- (NSString*)getItem:(NSString *)key
{
    NSString *value = [self.memory objectForKey:key];

    return value;
//    [self updateTimestampForKey:key];
//    [self updateIndexForKey:key];
}


- (NSString *)filePathForKey:(NSString *)key
{
    NSString *safeFileName = [WXUtility md5:key];
    
    return [[self directory] stringByAppendingPathComponent:safeFileName];
}



-(NSString *)stringWithContentsOfFile:(NSString *)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
        if (contents) {
            return contents;
        }
    }
    return nil;
}

- (NSString *)filePath {
    static NSString *storageFilePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storageFilePath = [[self directory] stringByAppendingPathComponent:@"wxstorage.plist"];
    });
    return storageFilePath;
}

-(MYWXThreadSafeMutableDictionary<NSString *, NSString *> *)memory {
    static MYWXThreadSafeMutableDictionary<NSString *,NSString *> *memory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupDirectory];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self filePath]]) {
            NSDictionary *contents = [NSDictionary dictionaryWithContentsOfFile:[self filePath]];
            if (contents) {
                memory = [[MYWXThreadSafeMutableDictionary alloc] initWithDictionary:contents];
            }
        }
        if (!memory) {
            memory = [MYWXThreadSafeMutableDictionary new];
        }
        //        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:nil usingBlock:^(__unused NSNotification *note) {
        //            [memory removeAllObjects];
        //        }];
    });
    return memory;
}

- (void)setupDirectory{
    BOOL isDirectory = NO;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self directory] isDirectory:&isDirectory];
    if (!isDirectory && !fileExists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[self directory]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    };
}

-(NSString *)directory {
    static NSString *storageDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storageDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        storageDirectory = [storageDirectory stringByAppendingPathComponent:WXStorageDirectory];
    });
    return storageDirectory;
}

#pragma mark --蓝牙相关
//开始扫描
- (void)beginScanPerpheral:(WXModuleKeepAliveCallback)callBack{
    self.beginScanPerpheralHandler = callBack;
    self.scanNum = 0;
    [self.bluetoothManage beginScanPerpheralSuccess:^(NSArray<CBPeripheral *> *peripherals, NSArray<NSNumber *> *rssis) {
        if (self.beginScanPerpheralHandler && self.scanNum < scanMaxNumber) {
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
            self.beginScanPerpheralHandler([nameArray mj_JSONString], YES);
        }
    } failure:^(CBManagerState status) {
        if (self.beginScanPerpheralHandler) {
            self.beginScanPerpheralHandler(@"请先打开蓝牙", YES);
        }
    }];
}

//自动连接蓝牙
- (void)autoConnectLastPeripheral:(WXModuleKeepAliveCallback)callBack{

    self.autoConnectLastPeripheralHandler = callBack;
    [self.bluetoothManage autoConnectLastPeripheralCompletion:^(CBPeripheral *perpheral, NSError *error) {
        if (!error) {
            if (self.autoConnectLastPeripheralHandler) {
                self.autoConnectLastPeripheralHandler(perpheral.name, YES);
            }
        }else{
            if (self.autoConnectLastPeripheralHandler) {
                self.autoConnectLastPeripheralHandler(error.domain, YES);
            }
        }
    }];
}

//手动连接
- (void)connectPeripheral:(NSInteger)index callBack:(WXModuleKeepAliveCallback)callBack{
    if (index >= self.buletoothDataArray.count) {
        [SVProgressHUD showInfoWithStatus:@"下标不正确"];
        return;
    }
    NSLog(@"%@",self.buletoothDataArray);
    self.connectSuccessHandler = callBack;
    [self.bluetoothManage connectPeripheral:self.buletoothDataArray[index] completion:^(CBPeripheral *perpheral, NSError *error) {
        if (!error) {
            if (self.connectSuccessHandler) {
                self.connectSuccessHandler(@"1", YES);
            }
        }else{
            if (self.connectSuccessHandler) {
                self.connectSuccessHandler(@"0", YES);
            }
        }
    }];
    
}

//蓝牙打印
- (void)bluetoothPrinte:(id)dict callBack:(WXModuleKeepAliveCallback)callBack{
    NSString *jsonString = dict;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    self.bluetoothPrinteStatusHandler = callBack;
    if (self.bluetoothManage.stage != JWScanStageCharacteristics) {
        if (self.bluetoothPrinteStatusHandler) {
            self.bluetoothPrinteStatusHandler(@"2", YES);
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
    [self.bluetoothManage sendPrintData:data completion:^(BOOL completion, CBPeripheral *peripheral, NSString *errorString) {
        if (completion) {
            if (self.bluetoothPrinteStatusHandler) {
                self.bluetoothPrinteStatusHandler(@"1", YES);
            }
        }else{
            if (self.bluetoothPrinteStatusHandler) {
                self.bluetoothPrinteStatusHandler(@"0", YES);
            }
        }
    }];
}
    
#pragma mark --检查更新
- (void)checkVersion:(NSString *)appId callBack:(WXModuleKeepAliveCallback)callBack{
    [[WeexNativeSupportManage shareManage] checkVersionToUpdateWithUrl:nil appId:appId isShowLatestVersionTips:YES];
}
    
- (void)getVersion:(WXModuleKeepAliveCallback)callBack{
    self.getVersionHandler = callBack;
    if (self.getVersionHandler) {
        self.getVersionHandler([[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"], YES);
    }
}

#pragma mark -- 淘宝优惠券
- (void)getCoupon:(NSString *)string callBack:(WXModuleKeepAliveCallback)callBack{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}

#pragma mark--获取ssid信息
- (void)getSSIDInfo:(WXModuleKeepAliveCallback)callBack {
    self.SSIDHandler = callBack;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@ ---%@", ifnam,info,NSStringFromClass([info class]));
        if (info && [info count]) { break; }
    }
    if (self.SSIDHandler) {
        self.SSIDHandler(info, YES);
    }
}

#pragma mark --上传日志

- (void)upLoadLogInfo:(WXModuleKeepAliveCallback)callBack{
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


#pragma mark -- 日志打印
- (void)printeLogInfoWithLog:(id)log callBack:(WXModuleKeepAliveCallback)callBack{
    DDLogDebug(@"%@",log);
}

#pragma mark -- 分享纯图片
- (void)activityShareWithImageUrlArray:(NSArray *)urlArray callBack:(WXModuleKeepAliveCallback)callBack{
    [[WeexNativeSupportManage shareManage] activityShareWithImageUrlArray:urlArray];
}

#pragma mark --setter\getter

- (JWBluetoothManage *)bluetoothManage{
    if (!_bluetoothManage) {
        _bluetoothManage = [JWBluetoothManage sharedInstance];
    }
    return _bluetoothManage;
}

-(NSMutableArray *)buletoothDataArray{
    if (!_buletoothDataArray) {
        _buletoothDataArray = [NSMutableArray array];
    }
    return _buletoothDataArray;
}

@end
