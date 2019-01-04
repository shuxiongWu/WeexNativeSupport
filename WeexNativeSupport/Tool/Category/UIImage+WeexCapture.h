//
//  UIImage+Capture.h
//  WeexDemo
//
//  Created by 超盟 on 2018/9/19.
//  Copyright © 2018年 wusx. All rights reserved.
//  将View截取生成Image

#import <UIKit/UIKit.h>

@interface UIImage (WeexCapture)
//截图功能
+ (UIImage *)captureImageFromView:(UIView *)view;
@end
