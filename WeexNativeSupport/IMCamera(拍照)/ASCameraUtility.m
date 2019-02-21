//
//  ASCameraUtility.m
//  PlayCarParadise
//
//  Created by wushuxiong on 2018/5/24.
//  Copyright © 2018年 CarFun. All rights reserved.
//

#import "ASCameraUtility.h"
#import <SVProgressHUD.h>
#import "DLHDActivityIndicator.h"

@implementation ASCameraUtility


+ (void)showProgressDialogText:(NSString *)text {
    DLHDActivityIndicator *indicator = [DLHDActivityIndicator shared];
    [indicator showWithLabelText:text];
}

+ (void)showAllTextDialog:(UIView *)view  Text:(NSString *)text{
    if (!view) {
        return;
    }
    if ([view isKindOfClass:[UITableView class]]) {
        view = view.superview;
    }
    [SVProgressHUD showWithStatus:text];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
//    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
//    [view addSubview:HUD];
//    HUD.margin = 12.f;
//    HUD.detailsLabel.text = text;
//    HUD.detailsLabel.font = [UIFont systemFontOfSize:14.0f];
//    HUD.mode = MBProgressHUDModeText;
//
//    //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
//    //    HUD.yOffset = 150.0f;
//    //    HUD.xOffset = 100.0f;
//
//    [HUD showAnimated:YES whileExecutingBlock:^{
//        sleep(1.5);
//    } completionBlock:^{
//        [HUD removeFromSuperview];
//    }];
}

+ (void)hideProgressDialog {
    [DLHDActivityIndicator hideActivityIndicator];
}


@end
