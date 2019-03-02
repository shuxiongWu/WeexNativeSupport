//
//  WeexLocationManage.m
//  WeexDemo
//
//  Created by 超盟 on 2018/9/26.
//  Copyright © 2018年 wusx. All rights reserved.
//

#import "WeexLocationManage.h"
#import <MJExtension.h>

@interface WeexLocationManage ()<CLLocationManagerDelegate,UIAlertViewDelegate>{//添加代理协议 CLLocationManagerDelegate
    CLLocationManager *_locationManager;//定位服务管理类
}

@end

@implementation WeexLocationManage

static WeexLocationManage *manager = nil;
+ (instancetype)shareManage {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        manager = [[WeexLocationManage alloc] init];
        [manager initLocationService];
    });
    return manager;
    
}

- (void)initLocationService{
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestWhenInUseAuthorization];
    //[_locationManager requestAlwaysAuthorization];//iOS8必须，这两行必须有一行执行，否则无法获取位置信息，和定位
    // 设置代理
    _locationManager.delegate = self;
    // 设置定位精确度到米
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // 设置过滤器为无
    _locationManager.distanceFilter = kCLDistanceFilterNone;
}

- (void)startLocation{
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"打开[定位服务]来允许访问您的位置" message:@"请在系统设置中开启定位服务(设置>隐私>定位服务>开启)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置" , nil];
        alertView.delegate = self;
        alertView.tag = 1;
        [alertView show];
        
    }
    [_locationManager startUpdatingLocation];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            //跳转到定位权限页面
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [_locationManager stopUpdatingLocation]; //不用的时候关闭更新位置服务
    NSLog(@"#####%lu",(unsigned long)locations.count);
    CLLocation * location = locations.lastObject;
    if (self.locationCallBack) {
        self.locationCallBack([@{@"longitude": @(location.coordinate.longitude), @"latitude": @(location.coordinate.latitude)} mj_JSONString], NO);
    }
}


@end

