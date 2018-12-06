//
//  MapViewCtl.m
//  LocationDemo
//
//  Created by Zec on 2018/6/26.
//  Copyright © 2018年 Zec. All rights reserved.
//

#import "MapViewCtl.h"
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotationView.h>
#import <WeexSDK/WXSDKManager.h>
#import "WeexNativeSupport.h"
#import <MAMapKit/MAMapKit.h>
#import<AMapFoundationKit/AMapFoundationKit.h>
#import<AMapLocationKit/AMapLocationKit.h>

@interface MapViewCtl ()<MAMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MAMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *locatedAddressLbl;
@property (weak, nonatomic) IBOutlet UITextField *addressTfd;
@property (weak, nonatomic) IBOutlet UIImageView *annotationView;
@property (nonatomic, assign) MKCoordinateSpan span;
@property (nonatomic, strong) MKPointAnnotation *pointAnnotaiton;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewBottomConstraint;
@property (nonatomic, copy) NSString *address;
@property (weak, nonatomic) IBOutlet UIImageView *textBoxImageView;

@property (nonatomic, assign) CLLocationCoordinate2D currentCoordinate;

@property (nonatomic, strong) AMapLocationManager *locationManager;  //位置管理类


// 地理反编码信息
// 省
@property (nonatomic, copy) NSString *state;
// 市
@property (nonatomic, copy) NSString *city;
// 区
@property (nonatomic, copy) NSString *district;
// 具体位置
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *detailAddress;

@end

@implementation MapViewCtl


// MARK: - Life Cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"地址保存";
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    saveBtn.frame = CGRectMake(0, 0, 60, 40);
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view layoutIfNeeded];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self keyboardDown];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _mapView.mapType = MAMapTypeStandard;// 设置地图模式
    _mapView.desiredAccuracy = kCLLocationAccuracyBest;// 设置定位精度
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_mapView setZoomLevel:(15.0f) animated:YES];// 设置地图缩放级别
    //_mapView.customizeUserLocationAccuracyCircleRepresentation = YES;//是否自定义用户位置精度圈
    _mapView.centerCoordinate = self.mapView.userLocation.coordinate;
    _mapView.pausesLocationUpdatesAutomatically = NO;
    _mapView.showsUserLocation = YES;
    _mapView.scrollEnabled = NO;
    _mapView.delegate = self;
    _mapView.rotateEnabled = NO;
    _mapView.showTraffic = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    //创建管理器对象
    self.locationManager = [[AMapLocationManager alloc] init];
    
    //设置精度
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self updateLocation];
}

- (void)updateLocation {
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (location) {
            self.mapView.centerCoordinate = location.coordinate;
        }
        if (regeocode) {
            self.state = regeocode.province;
            self.city = regeocode.city;
            self.district =  regeocode.district;
            self.name =  regeocode.street;
            
            NSString *strLocation;
            if ([regeocode.province isEqualToString:@"(null)"] && [regeocode.city isEqualToString:@"(null)"] && [regeocode.district isEqualToString:@"(null)"] && [regeocode.street isEqualToString:@"(null)"]) {
                strLocation = @"不能获取到当前位置";
            }
            else{
                strLocation= [NSString stringWithFormat:@"%@%@%@",[regeocode.province isEqualToString:@"(null)"] ? @"" : regeocode.province,[regeocode.city isEqualToString:@"(null)"]?@"":regeocode.city,[regeocode.district isEqualToString:@"(null)"]?@"":regeocode.district];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.locatedAddressLbl.text = strLocation;
                self.addressTfd.text = regeocode.street;
            });
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: - Public

// MARK: - Event Respone
- (void)saveBtnEvent:(UIButton *)sender
{
    NSString *address = [NSString stringWithFormat:@"%@%@%@",(self.state && self.state.length) ? self.state : @"", (self.city && self.city.length) ? self.city : @"", (self.district && self.district.length) ? self.district : @""];
    if (!address.length && !self.addressTfd.text.length) {
        [SVProgressHUD showInfoWithStatus:@"地址不能为空"];
        return;
    }
    
    self.locationAddressBlk ? self.locationAddressBlk(self.currentCoordinate.longitude, self.currentCoordinate.latitude, address, self.addressTfd.text) : nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)locationBtnEvent:(id)sender {
    [self updateLocation];
}

- (void)keyboardWillShow:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    CGRect frame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval timeInterval = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    __weak typeof(self) weakself = self;
    self.inputViewBottomConstraint.constant = frame.size.height + 15;
    
    [UIView setAnimationCurve:curve];
    [UIView animateWithDuration:timeInterval animations:^{
        [weakself.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NSTimeInterval timeInterval = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    __weak typeof(self) weakself = self;
    self.inputViewBottomConstraint.constant = 30;
    
    [UIView setAnimationCurve:curve];
    [UIView animateWithDuration:timeInterval animations:^{
        [weakself.view layoutIfNeeded];
    }];
}

- (void)keyboardDown
{
    [self.addressTfd resignFirstResponder];
}

@end
