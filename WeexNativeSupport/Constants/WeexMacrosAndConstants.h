//
//  MacrosAndConstants.h
//  WeexDemo
//
//  Created by 超盟 on 2018/9/11.
//  Copyright © 2018年 taobao. All rights reserved.
//
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "UIColor+WeexHex.h"
#ifndef MacrosAndConstants_h
#define MacrosAndConstants_h

//RGB转UIColor（不带alpha值）
#define UIColorFromRGB(rgbValue) [UIColor  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//当前设备的屏幕尺寸
#define kScreenWidth     [UIScreen mainScreen].bounds.size.width
#define kScreenHeight    [UIScreen mainScreen].bounds.size.height
//尺寸
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

// 十六进制颜色设置
#define SetColor(color,a) [UIColor colorwithHExString:[NSString stringWithFormat:@"%@",color] alpha:a]

#pragma mark-------NSUserDefaults------------

#define kUserDefaults(object,key) [[NSUserDefaults standardUserDefaults] setObject:object forKey:key] // 写
#define kUserSynchronize [[NSUserDefaults standardUserDefaults] synchronize] // 存
#define getUserDefaults(key) [[NSUserDefaults standardUserDefaults] objectForKey:key] // 取

#define Font(size)    [UIFont systemFontOfSize:size*PXSCALE]

/************部分页面，iPhonex 距离顶部适配********************/
#define CMJFToTop_X   94
#define CMJFToTop_o   74
#define CMJFNavHeight_X  88
#define CMJFNavHeight_o  64
#define CMJFTabHeight_X  83
#define CMJFTabHeight_o  49

#define CMJFiPhone_X   (kScreenHeight == 812)
#define CMJFStatus_height (CMJFiPhone_X ? 44 : 20)
#define CMJFNavBarHeight 44
#define CMJFNavHeight (CMJFStatus_height + CMJFNavBarHeight)
#define CMJFTabHeight (CMJFiPhone_X ? 83 :

#define CMJFDeviceToken @"CMSLDeviceToken" //
#define CMJFAccount @"CMJFAccount" //当前登录的账号

#define ScaleHeight(H)  [[UIScreen mainScreen] bounds].size.height/667*(H)

#define Color(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define FontColor Color(51, 51, 51)

///比例系数
#define PXSCALE  ScreenW/375
#define Font(size)    [UIFont systemFontOfSize:size*PXSCALE]

//通过DEBUG模式设置全局日志等级，DEBUG时为Verbose，所有日志信息都可以打印，否则Error，只打印

//#ifdef DEBUG
//static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
//#else
//static const DDLogLevel ddLogLevel = DDLogLevelError;
//#endif


#define CMJFlocalVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define ios_version [[UIDevice currentDevice].systemVersion floatValue]
#endif /* MacrosAndConstants_h */
