//
//  CMBaseService.h
//  WeexDemo
//
//  Created by 超盟 on 2018/9/10.
//  Copyright © 2018年 wushuxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeexBaseNetworkingService.h"
@interface WeexBaseService : NSObject
+ (void)getAppVersionWithUrl:(NSString *)url
     isShowLatestVersionTips:(BOOL)isShow
                     success:(successHandle)success
                     failure:(failureHandle)failure;
@end
