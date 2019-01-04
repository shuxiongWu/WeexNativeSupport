//
//  CMQRViewController.h
//  WeexDemo
//
//  Created by 吴述雄 on 2018/11/26.
//  Copyright © 2018 wusx. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ScanCallBack)(int code, NSString *msg);
@interface WeexQRViewController : UIViewController
@property (nonatomic, copy) ScanCallBack scanCallBack;
@end
