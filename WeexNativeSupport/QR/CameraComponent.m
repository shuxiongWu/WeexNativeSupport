//
//  CameraComponent.m
//  WeexDemo
//
//  Created by yMac on 2019/12/2.
//  Copyright © 2019 wusx. All rights reserved.
//

#import "CameraComponent.h"
#import <WeexSDK/WeexSDK.h>
#import "WeexScanView.h"
#import "WeexNativeScanTool.h"
#import "WeexPublicTool.h"

// 判断是否全面屏
#define kFullScreen ({\
BOOL isiPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
UIWindow *window = [UIApplication sharedApplication].delegate.window;\
if (window.safeAreaInsets.bottom > 0.0) {\
isiPhoneX = YES;\
}\
}\
isiPhoneX;\
})

@interface CameraComponent ()

@property (nonatomic, strong)  WeexNativeScanTool *scanTool;
@property (nonatomic, strong)  WeexScanView *scanView;

@property (nonatomic, assign) BOOL scanReuslt;

@end

@implementation CameraComponent


+ (void)load {
    [WXSDKEngine registerComponent:@"zxing" withClass:NSClassFromString(@"CameraComponent")];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"CameraComponent dealloc");
}

- (UIView *)loadView {
    return [UIView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    [self configuration];
    //监听是否触发home键挂起程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive)
    name:UIApplicationWillResignActiveNotification object:nil];
    // App进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground)
    name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)applicationWillResignActive {
    NSLog(@"App 退出到后台");
    [self stopCamera];
}

- (void)applicationWillEnterForeground {
    NSLog(@"App 进入前台");
    [self startCamera];
}

- (void)startCamera {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    if (_scanTool && _scanView) {
        [self.scanTool sessionStartRunning];
        [self.scanView startScanAnimation];
    }
}
- (void)stopCamera {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [_scanView stopScanAnimation];
    [_scanView finishedHandle];
    [_scanView showFlashSwitch:NO];
    [_scanTool sessionStopRunning];
}

- (void)configuration {
    /// 相机权限
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined:[self showAuthorizationNotDetermined]; break;// 用户尚未决定授权与否，那就请求授权
        case AVAuthorizationStatusAuthorized: break;// 用户已授权，那就立即使用
        case AVAuthorizationStatusDenied:[self showAuthorizationDenied]; break;// 用户明确地拒绝授权，那就展示提示
        case AVAuthorizationStatusRestricted:[self showAuthorizationRestricted]; break;// 无法访问相机设备，那就展示提示
    }
    
    
    //输出流视图
    UIView *preview  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 0)];
    [self.view addSubview:preview];
    
    __weak typeof(self) weakSelf = self;
    
    //[_back setBackgroundImage:[PublicTool wx_imageNamed:@"btn_back"] forState:UIControlStateNormal];
    //构建扫描样式视图
    _scanView = [[WeexScanView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    CGFloat x = 60.f;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 120);
    CGFloat height = ([UIScreen mainScreen].bounds.size.width - 120);
    CGFloat y = ([UIScreen mainScreen].bounds.size.height)/2 - width/2;
    
    _scanView.scanRetangleRect = CGRectMake(x, y, width, height);
    _scanView.colorAngle = [UIColor greenColor];
    _scanView.photoframeAngleW = 20;
    _scanView.photoframeAngleH = 20;
    _scanView.photoframeLineW = 2;
    _scanView.isNeedShowRetangle = YES;
    _scanView.colorRetangleLine = [UIColor whiteColor];
    _scanView.notRecoginitonArea = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _scanView.animationImage = [WeexPublicTool wx_imageNamed:@"scanLine"];
    _scanView.myQRCodeBlock = ^{
        
    };
    _scanView.flashSwitchBlock = ^(BOOL open) {
        [weakSelf.scanTool openFlashSwitch:open];
    };
    _scanView.descriptionString = @"";
    [self.view addSubview:_scanView];
    
    //初始化扫描工具
    _scanTool = [[WeexNativeScanTool alloc] initWithPreview:preview andScanFrame:_scanView.scanRetangleRect];
    _scanTool.scanFinishedBlock = ^(NSString *scanString) {
        NSLog(@"扫描结果 %@",scanString);
        [weakSelf.scanTool sessionStopRunning];
        [weakSelf.scanTool openFlashSwitch:NO];
        [weakSelf fireEvent:@"scanReuslt" params:@{@"code":@"1",@"code_url":scanString}];
        [[weakSelf currentViewController].navigationController popViewControllerAnimated:YES];
    };
    _scanTool.monitorLightBlock = ^(float brightness) {
        //        NSLog(@"环境光感 ： %f",brightness);
        if (brightness < 0) {
            // 环境太暗，显示闪光灯开关按钮
            [weakSelf.scanView showFlashSwitch:YES];
        }else if(brightness > 0){
            // 环境亮度可以,且闪光灯处于关闭状态时，隐藏闪光灯开关
            if(!weakSelf.scanTool.flashOpen){
                [weakSelf.scanView showFlashSwitch:NO];
            }
        }
    };
    [weakSelf.scanTool sessionStartRunning];
    [weakSelf.scanView startScanAnimation];
    [self startCamera];
}

- (void)addEvent:(NSString *)eventName {
    if ([eventName isEqualToString:@"scanReuslt"]) {
        _scanReuslt = YES;
    }
}

- (void)removeEvent:(NSString *)eventName {
    if ([eventName isEqualToString:@"scanReuslt"]) {
        _scanReuslt = NO;
    }
}

#pragma mark - 重写Weex方法
- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance {
    
    if ( self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        
        
    }
    
    return self;
}
//更新attributes时，同步属性
- (void)updateAttributes:(NSDictionary *)attributes {
    
    
}

#pragma mark - 相机使用权限处理
#pragma mark 用户还未决定是否授权使用相机
-(void)showAuthorizationNotDetermined {
    __weak typeof(self) weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            
        } else {
            [weakSelf showAuthorizationDenied];
        }
    }];
}

#pragma mark 未被授权使用相机
-(void)showAuthorizationDenied {
    //无权限
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法访问相机" message:@"请在设置-隐私-相机中允许访问相机" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[self currentViewController].navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *settings = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[self currentViewController].navigationController popViewControllerAnimated:YES];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self currentViewController] presentViewController:alert animated:YES completion:nil];
    });
    
}
#pragma mark 使用相机设备受限
-(void)showAuthorizationRestricted {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法访问相机" message:@"请检查您的手机硬件或设置" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[self currentViewController].navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:cancel];
    [[self currentViewController] presentViewController:alert animated:YES completion:nil];
}

- (UIViewController *)currentViewController {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    return vc;
}


@end
