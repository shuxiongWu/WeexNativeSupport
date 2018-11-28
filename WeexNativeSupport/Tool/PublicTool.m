//
//  PublicTool.m
//  WeexDemo
//
//  Created by 吴述雄 on 2018/11/27.
//  Copyright © 2018 wusx. All rights reserved.
//

#import "PublicTool.h"

@implementation PublicTool
+ (UIImage *)wx_imageNamed:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    if (image) {
        return image;
    }
    NSString *path = [NSString stringWithFormat:@"HXPhotoPicker.bundle/%@",imageName];
    image = [UIImage imageNamed:path];
    if (image) {
        return image;
    } else {
        NSString *path = [NSString stringWithFormat:@"Frameworks/HXPhotoPicker.framework/HXPhotoPicker.bundle/%@",imageName];
        image = [UIImage imageNamed:path];
        if (!image) {
            image = [UIImage imageNamed:imageName];
        }
        return image;
    }
}

@end
