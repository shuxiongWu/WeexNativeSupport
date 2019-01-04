//
//  UIImage+XJSCompress.m
//  BananaSays
//
//  Created by Zec on 2018/3/6.
//  Copyright © 2018年 Zec. All rights reserved.
//

#import "UIImage+WeexCompress.h"

@implementation UIImage (XJSCompress)

- (NSData *)zec_compress
{
    CGSize size = [self imageSize];
    
    UIImage *image = [self resizedImage:size];
    
    NSData *data = [image compressQualityWithMaxLength:1024 * 50];
    
    return data;
}

- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength {
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(self, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    return data;
}


- (CGSize)imageSize;
{
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    
    CGFloat boundary = 500;
    
    if (width < boundary || height < boundary) {
        return CGSizeMake(width, height);
    }
    CGFloat s = MAX(width, height) / MIN(width, height);
    if (s <= 2) {
        CGFloat x = MAX(width, height) / boundary;
        if (width > height) {
            width = boundary;
            height = height / x;
        } else {
            height = boundary;
            width = width / x;
        }
    } else {
        if (MIN(width, height) >= boundary) {
            CGFloat x = MIN(width, height) / boundary;
            if (width < height) {
                width = boundary;
                height = height / x;
            } else {
                height = boundary;
                width = width / x;
            }
        }
    }
    return CGSizeMake(width, height);
}

- (UIImage *)resizedImage:(CGSize)size
{
    CGRect newRect = CGRectMake(0, 0, size.width, size.width);
    UIGraphicsBeginImageContext(newRect.size);
    UIImage *image = [UIImage imageWithCGImage:self.CGImage scale:1 orientation:self.imageOrientation];
    [image drawInRect:newRect];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
