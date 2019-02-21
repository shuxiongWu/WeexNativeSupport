//
//  ASCameraMacro.h
//  PlayCarParadise
//
//  Created by lw on 2018/5/24.
//  Copyright © 2018年 CarFun. All rights reserved.
//

#ifndef ASCameraMacro_h
#define ASCameraMacro_h

#import "ASCameraUtility.h"


// 日志输出
#ifdef DEBUG
#define Plog(...) NSLog(__VA_ARGS__)
#else
#define Plog(...)
#endif

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;


#define KAppDelegate ((AppDelegate*)[UIApplication sharedApplication].delegate)

//得到屏幕width
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
//尺寸
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height
#endif /* ASCameraMacro_h */
