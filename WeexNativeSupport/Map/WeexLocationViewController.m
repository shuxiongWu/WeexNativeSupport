//
//  LocationViewController.m
//  PlayCarParadise
//
//  Created by 吴述雄 on 2017/11/11.
//  Copyright © 2017年 CarFun. All rights reserved.
//

#import "WeexLocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MapKit/MapKit.h>
#import <MAMapKit/MAMapKit.h>
#import "WeexCurrentLocationTableViewCell.h"
#import <UIView+MJExtension.h>
#import <MJRefresh.h>
#import <SVProgressHUD.h>
#import "WeexAddressModel.h"
#import "WeexPublicTool.h"
@interface WeexLocationViewController ()<AMapLocationManagerDelegate,AMapSearchDelegate,MAMapViewDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) AMapLocationManager* locationManager;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet MAMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *annotationImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navViewHeight;
@property (nonatomic, strong) NSMutableArray *dataSrouce;
@property (nonatomic, assign) CGFloat mapView_y;
@property (nonatomic, assign) CGFloat tableView_y;
@property (nonatomic, assign) CGFloat tableView_h;
@property (nonatomic, weak) UIButton *againLocation;
@property (nonatomic, assign) UIStatusBarStyle barStyle;
@end

@implementation WeexLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataSrouce];
    
    [self initSetting];
    //开始持续定位
    [self findMe];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self findMe];
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"打开[定位服务]来允许访问您的位置" message:@"请在系统设置中开启定位服务(设置>隐私>定位服务>开启)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置" , nil];
        alertView.delegate = self;
        alertView.tag = 1;
        [alertView show];
        
    }
    self.barStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
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

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = self.barStyle;
    _mapView.delegate = nil;
    _locationManager.delegate = nil;
    _search.delegate = nil;
    _searchBar.delegate = nil;
}

- (void)dealloc {
//    NSLog(@"WeexLocationViewController dealloc==================================");
}

/**
 * @brief 地图将要发生移动时调用此接口
 * @param mapView 地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction{
    [self.view endEditing:YES];
    if (wasUserAction) {
        _dataSrouce[0] = @[];
    }
}
/// 单击地图
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
    [self.view endEditing:YES];
}

#pragma mark --- 地图区域改变完成后会调用此接口
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:mapView.region.center.latitude longitude:mapView.region.center.longitude];
    request.keywords = @"";
//    NSLog(@"%@",request.location);
    /* 按照距离排序. */
    request.sortrule = 0;
    request.requireExtension = YES;
    [self.search AMapPOIAroundSearch:request];
    [self popJumpAnimationView:_annotationImgView];
}

//标注跳动动画
- (void)popJumpAnimationView:(UIView *)sender
{
    CGFloat duration = 1.f;
    CGFloat height = 15.f;
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    CGFloat currentTy = sender.transform.ty;
    animation.duration = duration;
    animation.values = @[@(currentTy), @(currentTy - height/4), @(currentTy-height/4*2), @(currentTy-height/4*3), @(currentTy - height), @(currentTy-height/4*3), @(currentTy -height/4*2), @(currentTy - height/4), @(currentTy)];
    animation.keyTimes = @[ @(0), @(0.025), @(0.085), @(0.2), @(0.5), @(0.8), @(0.915), @(0.975), @(1) ];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = HUGE_VALF;
    [sender.layer addAnimation:animation forKey:@"kViewShakerAnimationKey"];
}

//增加重新定位按钮
- (void)addStartUpdatingLocation{
    if (_againLocation) {
        return;
    }
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locationButton setImage:[WeexPublicTool wx_imageNamed:@"location"] forState:UIControlStateNormal];
    [locationButton addTarget:self action:@selector(findMe) forControlEvents:UIControlEventTouchUpInside];
    locationButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 55, 180, 40, 40);
    _againLocation = locationButton;
    [self.mapView addSubview:locationButton];
}

-(void)viewDidLayoutSubviews{
    _tableView_y = _tableView.mj_y;
    _mapView_y = _mapView.mj_y;
    _tableView_h = _tableView.mj_h;
    [self.mapView bringSubviewToFront:_annotationImgView];
    [self addStartUpdatingLocation];
}

- (BOOL)isPhoneX {
    BOOL iPhoneX = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {//判断是否是手机
        return iPhoneX;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneX = YES;
        }
    }
    return iPhoneX;
}

- (void)initSetting{
    self.navViewHeight.constant = [self isPhoneX] ? 88 : 64;
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.tableView.tableFooterView = [UIView new];
    NSString* bundlePath = [[NSBundle mainBundle]pathForResource: @"HXPhotoPicker"ofType:@"bundle"];
    
    NSBundle *resourceBundle =[NSBundle bundleWithPath:bundlePath];
    [self.tableView registerNib:[UINib nibWithNibName:@"WeexCurrentLocationTableViewCell" bundle:resourceBundle] forCellReuseIdentifier:@"WeexCurrentLocationTableViewCell"];
    
    UIImage* searchBarBg = [self getImageWithColor:[UIColor colorWithRed:230/255.0 green:232/255.0 blue:235/255.0 alpha:1] andHeight:32.0f];
    //设置背景图片
    [_searchBar setBackgroundImage:searchBarBg];
    _searchBar.delegate = self;
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeNone;
    _mapView.showsScale = NO;
    _mapView.showsCompass = NO;
    _mapView.delegate = self;
    [_mapView setZoomLevel:16.1 animated:YES];
}

- (UIImage*)getImageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(r.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, r);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)loadNewTopic{
    //开始持续定位
    [self findMe];
}

- (void)searchAddress {
    [self.view endEditing:YES];
    if (_searchBar.text.length == 0) {
        //        [SVProgressHUD showInfoWithStatus:@"请输入搜索关键字"];
    } else {
        
        AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
        tips.keywords = _searchBar.text;
        //tips.city     = @"北京";
        //   tips.cityLimit = YES; 是否限制城市
        [self.search AMapInputTipsSearch:tips];
    }
}

/* 输入提示回调. */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    //解析response获取提示词，具体解析见 Demo
    _dataSrouce[0] = @[];
    if (response.count > 0) {
        AMapTip *firstPoi = [response.tips firstObject];
        /// 位置更新会再调搜索此点附近的地点
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(firstPoi.location.latitude, firstPoi.location.longitude);
//        NSMutableArray *addressArr = [NSMutableArray array];
//        for (AMapTip *poi in response.tips) {
//            WeexAddressModel *model = [[WeexAddressModel alloc] init];
//            model.longitude = poi.location.longitude;
//            model.latitude = poi.location.latitude;
//
//            model.title = poi.name;
//            model.subTitle = poi.address;
//            if (model.longitude > 0 || model.latitude > 0) {
//                [addressArr addObject:model];
//            }
//        }
//        if (_dataSrouce.count == 2) {
//            _dataSrouce[1] = addressArr;
//        }else{
//            [_dataSrouce addObject:addressArr];
//        }
//
//        [self.tableView reloadData];
    }
}

//捕捉搜索
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchAddress];
}
- (void)initDataSrouce{
    
    _dataSrouce = [NSMutableArray array];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > 0) {
        [UIView animateWithDuration:0.4 animations:^{
            self.mapView.mj_y = self.mapView_y - 60;
            self.tableView.mj_y = self.tableView_y - 120;
            self.tableView.mj_h = self.tableView_h + 120;
            self.againLocation.mj_y = 120;
        }];
    }else{
        [UIView animateWithDuration:0.4 animations:^{
            self.mapView.mj_y = self.mapView_y;
            self.tableView.mj_y = self.tableView_y;
            self.tableView.mj_h = self.tableView_h;
            self.againLocation.mj_y = 180;
        }];
    }
}

#pragma mark --UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSrouce.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = _dataSrouce[section];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = _dataSrouce[indexPath.section];
    WeexAddressModel *model = arr[indexPath.row];
    if (_locationAddressBlk) {
        _locationAddressBlk(
                                model.longitude,
                                model.latitude,
                                model.province,
                                model.city,
                                model.area,
                                model.title,
                                model.subTitle
                            );
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *arr = _dataSrouce[indexPath.section];
    WeexAddressModel *model = arr[indexPath.row];
    if (indexPath.section == 0) {
        WeexCurrentLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeexCurrentLocationTableViewCell"];
        cell.titleLabel.text = model.title;
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.textLabel.text = model.title;
    cell.detailTextLabel.text = model.subTitle;
    cell.detailTextLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    
    return cell;
}

-(AMapLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager setPausesLocationUpdatesAutomatically:NO];
    }
    return _locationManager;
}

- (void)findMe
{
    //开始持续定位
    [self.locationManager startUpdatingLocation];
    [self.locationManager setLocatingWithReGeocode:YES];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    WeexAddressModel *model = [[WeexAddressModel alloc] init];
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    model.longitude = location.coordinate.longitude;
    model.latitude = location.coordinate.latitude;
    
    model.province = reGeocode.province ?:@"";
    model.city = reGeocode.city ?:@"";
    model.area = reGeocode.district ?:@"";
    
    _coordinate = location.coordinate;
    _mapView.centerCoordinate = _coordinate;
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    if (reGeocode)
    {
        model.title = [NSString stringWithFormat:@"%@(%@%@)",reGeocode.POIName,reGeocode.street,reGeocode.number];
        model.subTitle = reGeocode.formattedAddress;
        if ([_dataSrouce count] > 0) {
            _dataSrouce[0] = @[model];
        }else{
            [_dataSrouce insertObject:@[model] atIndex:0];
        }
        
        [self.tableView reloadData];
        NSLog(@"reGeocode:%@", reGeocode);
        
        AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
        
        request.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        request.keywords = @"";
        /* 按照距离排序. */
        request.sortrule = 0;
        request.requireExtension = YES;
        [self.search AMapPOIAroundSearch:request];
        
        // 2.停止定位
        [manager stopUpdatingLocation];
    }
}

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error{
    if (error) {
        [self.tableView.mj_header endRefreshing];
        [SVProgressHUD showInfoWithStatus:@"定位失败"];
    }
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }else{
        NSMutableArray *addressArr = [NSMutableArray array];
        for (AMapPOI *poi in response.pois) {
            WeexAddressModel *model = [[WeexAddressModel alloc] init];
            model.longitude = poi.location.longitude;
            model.latitude = poi.location.latitude;
            
            model.province = poi.province ?:@"";
            model.city = poi.city ?:@"";
            model.area = poi.district ?:@"";
            
            model.title = poi.name;
            model.subTitle = poi.address;
            [addressArr addObject:model];
        }
//        if (_dataSrouce.count == 2) {
//            _dataSrouce[1] = addressArr;
//        }else{
//            [_dataSrouce removeAllObjects];
//            [_dataSrouce addObject:addressArr];
//        }
        if (_dataSrouce.count == 1) {
            [_dataSrouce addObject:addressArr];
        } else if (_dataSrouce.count == 2) {
            _dataSrouce[1] = addressArr;
        } else {
            [_dataSrouce removeAllObjects];
            [_dataSrouce addObject:@[]];
            [_dataSrouce addObject:addressArr];
        }
        [self.tableView reloadData];
    }
    //停止动画
    [_annotationImgView.layer removeAllAnimations];
    [self.tableView.mj_header endRefreshing];
    //解析response获取POI信息，具体解析见 Demo
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
}

- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
