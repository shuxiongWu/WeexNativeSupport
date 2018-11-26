//
//  CMWXProgressHUDModule.m
//  WeexDemo
//
//  Created by 吴述雄 on 2018/11/21.
//  Copyright © 2018 wusx. All rights reserved.
//

#import "CMWXProgressHUDModule.h"
#import <SVProgressHUD.h>
#import <WeexSDK/WeexSDK.h>
@interface CMWXProgressHUDModule ()

@end

@implementation CMWXProgressHUDModule

WX_EXPORT_METHOD(@selector(showHUDWithParams:))
    
+ (void)load{
    [WXSDKEngine registerModule:@"CMWXProgressHUDModule" withClass:[CMWXProgressHUDModule class]];
}

- (void)showHUDWithParams:(NSDictionary *)params{
    if (![params isKindOfClass:[NSDictionary class]]) return;
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    if ([params[@"status"] isEqualToString:@"success"]) {
        [SVProgressHUD showSuccessWithStatus:params[@"content"]];
    }else if ([params[@"status"] isEqualToString:@"error"]){
        [SVProgressHUD showErrorWithStatus:params[@"content"]];
    }else if ([params[@"status"] isEqualToString:@"info"]){
        [SVProgressHUD showInfoWithStatus:params[@"content"]];
    }else if ([params[@"status"] isEqualToString:@"normal"]){
        [SVProgressHUD showWithStatus:params[@"content"]];
    }else if ([params[@"status"] isEqualToString:@"dismiss"]){
        [SVProgressHUD dismiss];
    }else if ([params[@"status"] isEqualToString:@"show"]){
        [SVProgressHUD show];
    }
}
    

    
@end
