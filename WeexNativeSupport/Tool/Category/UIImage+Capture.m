//
//  UIImage+Capture.m
//  WeexDemo
//
//  Created by 超盟 on 2018/9/19.
//  Copyright © 2018年 wusx. All rights reserved.
//

#import "UIImage+Capture.h"

@implementation UIImage (Capture)

//截图功能
+ (UIImage *)captureImageFromView:(UIView *)view{
    
    UIGraphicsBeginImageContextWithOptions(view.frame.size,NO, 0);
    [[UIColor clearColor] setFill];
    [[UIBezierPath bezierPathWithRect:view.bounds] fill];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [view.layer renderInContext:ctx];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
