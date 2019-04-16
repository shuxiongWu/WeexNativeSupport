//
//  LocationViewController.h
//  PlayCarParadise
//
//  Created by 吴述雄 on 2017/11/11.
//  Copyright © 2017年 CarFun. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^LocationAddressBlock)(double longitude, double latitude ,NSString *province ,NSString *city ,NSString *area ,NSString *address, NSString *detailAddress);
@interface WeexLocationViewController : UIViewController


@property (nonatomic, copy) LocationAddressBlock locationAddressBlk;

@end
