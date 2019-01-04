//
//  UIImage+ScaleImage.h
//  WeexDemo
//
//  Created by 超盟 on 2018/9/18.
//  Copyright © 2018年 wusx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WeexScaleImage)

/**
 压缩图片到最大KB

 @param image 需要压缩的图片
 @param kb 最大kb
 @return 压缩后生成的图片
 */
+(UIImage *)scaleImage:(UIImage *)image toKb:(NSInteger)kb;
@end
