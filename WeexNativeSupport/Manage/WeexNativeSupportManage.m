//
//  WeexNativeSupportManage.m
//  WeexDemo
//
//  Created by 超盟 on 2018/9/14.
//  Copyright © 2018年 wusx. All rights reserved.
//

#import "WeexNativeSupportManage.h"
#import "CMBaseService.h"
#import "MJShareItem.h"
#import "UIImage+ScaleImage.h"
@interface WeexNativeSupportManage ()
    
@property (nonatomic, copy) NSString *url;  //存储域名
    
@end

@implementation WeexNativeSupportManage
static WeexNativeSupportManage *manager = nil;
+ (instancetype)shareManage {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        manager = [[WeexNativeSupportManage alloc] init];
    });
    return manager;
    
}
#pragma mark -- 检查更新
- (void)checkVersionToUpdateWithUrl:(NSString *)url appId:(NSString *)appId isShowLatestVersionTips:(BOOL)isShow{
    if (url) {
        _url = url;
    }else{
        NSLog(@"请在AppDelegate里面初始化检查更新");
        return;
    }
    [CMBaseService getAppVersionWithUrl:_url isShowLatestVersionTips:isShow success:^(id data, id msg, id is_force) {
        if ([[NSString stringWithFormat:@"%@",is_force] isEqualToString:@"1"]) {
            [self showAlertWithAppId:appId WithTitle:msg message:data sureBtn:@"现在升级" cancleBtn:nil];
        }
        else{
            [self showAlertWithAppId:appId WithTitle:msg message:data sureBtn:@"现在升级" cancleBtn:@"暂不升级"];
        }
    } failure:^(id error) {
        
    }];
}

- (void)showAlertWithAppId:(NSString *)appId WithTitle:(NSString *)title message:(NSString *)message sureBtn:(NSString *)sureString cancleBtn:(NSString *)cancelString{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (sureString) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:sureString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *itunsStr = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/us/id%@?mt=8",appId];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itunsStr]];
        }];
        [alertCtrl addAction:action];
    }
    if (cancelString) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:sureString style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertCtrl addAction:action];
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertCtrl animated:YES completion:nil];
}

#pragma mark -- 分享图片
- (void)activityShareWithImageUrlArray:(NSArray *)urlArray{
    
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    
    
    int i = 0;
    for (NSString *urlString  in urlArray) {
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        UIImage *image = [UIImage imageWithData:data]; // 取得图片
        
        //防止太大分享失败,目前微信限制最大是32kb
        [UIImage scaleImage:image toKb:32];
        
        //本地路径
        NSString *str = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *filePath = [NSString stringWithFormat:@"%@/huaji%d.jpg",str,i];
        //保存本地
        [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
        
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        //把图片和路径传进来
        MJShareItem *item = [[MJShareItem alloc] initWithImage:image andfile:fileURL];
        [mArray addObject:item];
        i++;
    }
    
    //里面initWithActivityItems  传的是item的数组  如果直接用图片数组的话 会经常出现 微信断开的错误
    UIActivityViewController *activityView =[[UIActivityViewController alloc] initWithActivityItems:mArray
                                                                              applicationActivities:nil];
    
    //需要忽略的分享
    activityView.excludedActivityTypes = @[
                                           UIActivityTypePrint,
                                           UIActivityTypeCopyToPasteboard,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeSaveToCameraRoll,
                                           UIActivityTypeMail,
                                           UIActivityTypePrint,
                                           UIActivityTypeCopyToPasteboard,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeSaveToCameraRoll,
                                           UIActivityTypeAddToReadingList,
                                           UIActivityTypePostToFlickr,
                                           UIActivityTypeAirDrop
                                           ];
    
    activityView.restorationIdentifier = @"activity";
    [activityView setTitle:@"分享"];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:activityView animated:TRUE completion:nil];
    
}

@end
