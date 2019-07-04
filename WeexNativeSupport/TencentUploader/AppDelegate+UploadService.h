//
//  AppDelegate+UploadService.h
//  VideoUploadDemo
//
//  Created by yMac on 2019/6/25.
//  Copyright © 2019 cs. All rights reserved.
//

#import "AppDelegate.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <QCloudCore/QCloudCore.h>


NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (UploadService)<QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

/// 腾讯云存储脚手架工具
//@property (nonatomic, strong) QCloudCredentailFenceQueue *credentialFenceQueue;

- (void)setupCOSXMLShareServiceWithRegionName:(NSString *)regionName
                                        appid:(NSString *)appid
                                  serviceName:(NSString *)serviceName;

@end

NS_ASSUME_NONNULL_END
