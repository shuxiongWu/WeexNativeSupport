//
//  AdressModel.h
//  WeexDemo
//
//  Created by 吴述雄 on 2018/12/24.
//  Copyright © 2018 wushuxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface WeexAddressModel : NSObject
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *subTitle;

@property (nonatomic, assign) CGFloat longitude;

@property (nonatomic, assign) CGFloat latitude;
@end
