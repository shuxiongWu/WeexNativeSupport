//
//  NSSQRViewController.m
//  CMfspay
//
//  Created by 超盟 on 2017/12/5.
//  Copyright © 2017年 超盟. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ScanCallBlock)(int code, NSString *msg);

@interface NSSQRViewController : UIViewController

@property (nonatomic, copy) NSString *price;

@property (nonatomic, copy) NSString *shopId;

@property (nonatomic, copy) NSString *codeId;

@property (nonatomic, assign) int qrType;//0 普通扫码  1首次认证 2扫描台卡 3营销卡券

@property (nonatomic, assign) BOOL idEnter;


@property (nonatomic, copy) ScanCallBlock scanCallBlk;

@end