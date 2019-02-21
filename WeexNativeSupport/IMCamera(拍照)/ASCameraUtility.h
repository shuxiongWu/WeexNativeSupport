//
//  ASCameraUtility.h
//  PlayCarParadise
//
//  Created by wushuxiong on 2018/5/24.
//  Copyright © 2018年 CarFun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ASCameraUtility : NSObject



//HUD
+ (void)showProgressDialogText:(NSString *)text;
+ (void)showAllTextDialog:(UIView *)view  Text:(NSString *)text;
+ (void)hideProgressDialog;

@end
