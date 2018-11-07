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


@interface MapViewCtl ()<MKMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
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
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];

    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
//    [self.view bringSubviewToFront:self.annotationView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDown)];
    [self.mapView addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)locationBtnEvent:(id)sender {
    self.mapView.showsUserLocation = YES;
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

// MARK: - Delegate
// MARK: MapKit
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    CLLocationCoordinate2D center = userLocation.coordinate;
    self.span = MKCoordinateSpanMake(0.005, 0.005);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, self.span);
    //    [self.locationManager stopUpdatingLocation];
    self.mapView.showsUserLocation = NO;
    [self.mapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationCoordinate2D center = mapView.region.center;
    MKCoordinateRegion region =MKCoordinateRegionMake(center, self.span);
    [self.mapView setRegion:region animated:YES];
    
//    if (self.pointAnnotaiton == nil)
//    {
//        self.pointAnnotaiton = [[MKPointAnnotation alloc] init];
//        [self.pointAnnotaiton setCoordinate:center];
//
//        [self.mapView addAnnotation:self.pointAnnotaiton];
//    }
//    [self.pointAnnotaiton setCoordinate:center];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    self.currentCoordinate = center;
    __weak typeof(self)weakSelf = self;
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        /*
         @property (nonatomic, readonly, copy, nullable) NSString *thoroughfare; // street name, eg. Infinite Loop
         @property (nonatomic, readonly, copy, nullable) NSString *subThoroughfare; // eg. 1
         @property (nonatomic, readonly, copy, nullable) NSString *locality; // city, eg. Cupertino
         @property (nonatomic, readonly, copy, nullable) NSString *subLocality; // neighborhood, common name, eg. Mission District
         @property (nonatomic, readonly, copy, nullable) NSString *administrativeArea; // state, eg. CA
         @property (nonatomic, readonly, copy, nullable) NSString *subAdministrativeArea; // county, eg. Santa Clara
         @property (nonatomic, readonly, copy, nullable) NSString *postalCode; // zip code, eg. 95014
         @property (nonatomic, readonly, copy, nullable) NSString *ISOcountryCode; // eg. US
         @property (nonatomic, readonly, copy, nullable) NSString *country; // eg. United States
         @property (nonatomic, readonly, copy, nullable) NSString *inlandWater; // eg. Lake Tahoe
         @property (nonatomic, readonly, copy, nullable) NSString *ocean; // eg. Pacific Ocean
         @property (nonatomic, readonly, copy, nullable) NSArray<NSString *> *areasOfInterest; // eg. Golden Gate Park
         */
//        CLPlacemark *placeMark = placemarks.firstObject;
//        NSLog(@"%@ %@ %@ %@", placeMark.name, placeMark.locality, placeMark.subLocality, placeMark.administrativeArea);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.state = placeMark.administrativeArea;
//            weakSelf.city = placeMark.locality;
//            weakSelf.district = placeMark.subLocality;
//            weakSelf.name = placeMark.name;
//            weakSelf.locatedAddressLbl.text = placeMark.name;
//        });
        
        
        if (error) {
            NSLog(@"反编码失败:%@",error);
        }else{
            CLPlacemark *placemark = placemarks.lastObject;
            
            NSLog(@"%@ %@ %@", placemark.name, placemark.thoroughfare, placemark.subThoroughfare);
            NSDictionary *addressDic= placemark.addressDictionary;
            
            NSString *state=[addressDic objectForKey:@"State"]?[addressDic objectForKey:@"State"]:@"(null)";
            NSString *city=[addressDic objectForKey:@"City"]?[addressDic objectForKey:@"City"]:@"(null)";
            NSString *subLocality=[addressDic objectForKey:@"SubLocality"]?[addressDic objectForKey:@"SubLocality"]:@"(null)";
            NSString *street=[addressDic objectForKey:@"Street"]?[addressDic objectForKey:@"Street"]:@"(null)";
            //NSLog(@"%@,%@,%@,%@",state,city,subLocality,street);
            
            weakSelf.state =state;
            weakSelf.city = city;
            weakSelf.district = subLocality;
            weakSelf.name = street;
//                        weakSelf.locatedAddressLbl.text = placeMark.name;
            
            NSString *strLocation;
            if ([state isEqualToString:@"(null)"] && [city isEqualToString:@"(null)"] && [subLocality isEqualToString:@"(null)"] && [street isEqualToString:@"(null)"]) {
                strLocation = @"不能获取到当前位置";
            }
            else{
                strLocation= [NSString stringWithFormat:@"%@%@%@",[state isEqualToString:@"(null)"]?@"":state,[city isEqualToString:@"(null)"]?@"":city,[subLocality isEqualToString:@"(null)"]?@"":subLocality];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.locatedAddressLbl.text = strLocation;
            });
        }
    }];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
//    [self.mapView setRegion:mapView.region animated:YES];
}


//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//{
//    if ([annotation isKindOfClass:[MKPointAnnotation class]])
//    {
//        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
//
//        MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
//        if (annotationView == nil)
//        {
//            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
//        }
//
//        annotationView.canShowCallout = YES;
//        annotationView.draggable = YES;//可以拖动
//        annotationView.image = [UIImage imageNamed:@"annotation"];
//
//        return annotationView;
//    }
//
//    return nil;
//}


// MARK: - Private

// MARK: - Getters and Setters
- (CLGeocoder *)geoCoder
{
    if (!_geoCoder) {
        _geoCoder = [[CLGeocoder alloc] init];
    }
    return _geoCoder;
}

// MARK: - Supperclass

// MARK: - NSObject



@end
