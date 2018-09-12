//
//  MapViewCtl.h
//  LocationDemo
//
//  Created by Zec on 2018/6/26.
//  Copyright © 2018年 Zec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef void(^LocationAddressBlock)(double longitude, double latitude ,NSString *address, NSString *detailAddress);
@interface MapViewCtl : UIViewController

@property (nonatomic, copy) LocationAddressBlock locationAddressBlk;

@end
