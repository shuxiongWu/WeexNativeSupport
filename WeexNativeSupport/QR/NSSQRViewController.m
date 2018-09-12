//
//  NSSQRViewController.m
//  CMfspay
//
//  Created by 超盟 on 2017/12/5.
//  Copyright © 2017年 超盟. All rights reserved.
//
#import "NSSQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "WeexNativeSupport.h"
#define TOP 110
#define LEFT (kScreenWidth-220)/2
#define kScanRect CGRectMake(LEFT, TOP, 220, 220)


@interface NSSQRViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    CAShapeLayer *cropLayer;
    NSString *lat;
    NSString *lng;
    NSString *serviceCode;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, strong) UIImageView * line;

@end

@implementation NSSQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configView];
    [self performSelector:@selector(setupCamera) withObject:nil afterDelay:0.1];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
}


#pragma mark--配置界面
-(void)configView{
    self.view.backgroundColor = [UIColor blackColor];
    [self setCropRect:kScanRect];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, CMJFStatus_height, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:kScanRect];
    imageView.image = [UIImage imageNamed:@"icon_green_box"];
    [self.view addSubview:imageView];
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT, TOP+10, 220, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 25, kScreenWidth, 20)];
    if (_qrType== 3) {
        lb.text = @"扫描有品业务员二维码";
    }
    else{
        lb.text = @"将二维码放入框内，即可扫描";
    }
    lb.font = [UIFont systemFontOfSize:14];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.textColor = [UIColor whiteColor];
    [self.view addSubview:lb];
    
    UIButton * lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lightBtn.frame = CGRectMake((kScreenWidth - 60)/2.0, CGRectGetMaxY(lb.frame) + 67, 60, 60);
    [lightBtn setImage:[UIImage imageNamed:@"icon_flashlight_normal"] forState:UIControlStateNormal];
    [lightBtn addTarget:self action:@selector(lightClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lightBtn];
}


-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, 220, 2);
        if (2*num == 200) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}


- (void)setCropRect:(CGRect)cropRect{
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, CGRectMake(0, 0, kScreenWidth, kScreenHeight));
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.5];
    [cropLayer setNeedsDisplay];
    [self.view.layer addSublayer:cropLayer];
}

- (void)setupCamera
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device==nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫描区域
    CGFloat top = TOP/kScreenHeight;
    CGFloat left = LEFT/kScreenWidth;
    CGFloat width = 220/kScreenWidth;
    CGFloat height = 220/kScreenHeight;
    ///top 与 left 互换  width 与 height 互换
    [_output setRectOfInterest:CGRectMake(top,left, height, width)];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"超盟食链" message:@"请在iPhone的“设置”-“隐私”-“相机”功能中，找到“超盟商+“打开相机访问权限" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    // Start
    [_session startRunning];
}

#pragma mark--代理
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [_session stopRunning];
        [timer setFireDate:[NSDate distantFuture]];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        NSLog(@"扫描结果：%@",stringValue);
        
//        NSArray *arry = metadataObject.corners;
//        for (id temp in arry) {
//            NSLog(@"%@",temp);
//        }
//        if (_session != nil && timer != nil) {
//            [_session startRunning];
//            [timer setFireDate:[NSDate date]];
//        }
//        NSString * board_id = getUserDefaults(@"uid");
//        NSString * board_num = getUserDefaults(@"token");
//        NSString * uid = getUserDefaults(@"uid");
//        NSString * token = getUserDefaults(@"token");
//        NSString * role_login = getUserDefaults(@"role_login");
//        NSString * sid = getUserDefaults(@"sid");

        
        self.scanCallBlk ? self.scanCallBlk(1,stringValue) : nil;
        [self.navigationController popViewControllerAnimated:YES];
        
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描结果" message:stringValue preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        }]];
//
//        [self presentViewController:alert animated:YES completion:nil];
//
        
        
//        NSString *url = @" http://localfapp.cmfspay.com/cater/setboard";
//        NSDictionary *parameters = @{@"uid":uid, @"token":token,@"role_login":role_login,@"sid":sid,@"board_id":board_id,@"board_num":board_num,@"action":@"bang",@"status":@"",@"code_url":stringValue};
//        [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:parameters error:nil];
    } else {
        NSLog(@"无扫描信息");
        return;
    }
    
}




#pragma mark--数据请求



#pragma mark--通知



- (void)back:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)lightClick:(UIButton *)btn{
    if (!btn.isSelected) {
        [btn setImage:[UIImage imageNamed:@"icon_flashlight_press"] forState:UIControlStateNormal];
    }
    else{
        [btn setImage:[UIImage imageNamed:@"icon_flashlight_normal"] forState:UIControlStateNormal];
    }
    [self openLight:btn];
    [btn setSelected:!btn.isSelected];
}

#pragma mark--业务
- (void)openLight:(UIButton *)sender{
    AVCaptureDevice *device = self.device;
    //修改前必须先锁定
    [self.device lockForConfiguration:nil];
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if ([self.device hasFlash]) {
        if (self.device.flashMode == AVCaptureFlashModeOff) {
            self.device.flashMode = AVCaptureFlashModeOn;
            self.device.torchMode = AVCaptureTorchModeOn;
        } else if (self.device.flashMode == AVCaptureFlashModeOn) {
            self.device.flashMode = AVCaptureFlashModeOff;
            self.device.torchMode = AVCaptureTorchModeOff;
        }
    }
    [device unlockForConfiguration];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
