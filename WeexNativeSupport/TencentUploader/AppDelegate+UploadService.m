//
//  AppDelegate+UploadService.m
//  VideoUploadDemo
//
//  Created by yMac on 2019/6/25.
//  Copyright © 2019 cs. All rights reserved.
//

#import "AppDelegate+UploadService.h"
#import <objc/runtime.h>



static const void *credentialFenceQueueKey = &credentialFenceQueueKey;

/*
 最后的URL = http://'kBucket'+ 'kRegionName' + 'kServiceName'/fileName?uploads
 like this: http://mobile-rental-1253836176.cos.gz.myqcloud.com/picture.jpg?uploads
 */

@interface AppDelegate ()

/// 腾讯云存储脚手架工具
@property (nonatomic, strong) QCloudCredentailFenceQueue *credentialFenceQueue;

@end

@implementation AppDelegate (UploadService)


- (QCloudCredentailFenceQueue *)credentialFenceQueue {
    return objc_getAssociatedObject(self, credentialFenceQueueKey);
}
- (void)setCredentialFenceQueue:(QCloudCredentailFenceQueue *)credentialFenceQueue {
    objc_setAssociatedObject(self, credentialFenceQueueKey, credentialFenceQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


////第一步：注册默认的cos服务
- (void)setupCOSXMLShareServiceWithRegionName:(NSString *)regionName
                                        appid:(NSString *)appid
                                  serviceName:(NSString *)serviceName {
    QCloudServiceConfiguration* configuration = [[QCloudServiceConfiguration alloc] init];
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = regionName;
    //设置bucket是前缀还是后缀，默认是yes为前缀（bucket.cos.wh.yun.ccb.com），设置为no即为后缀（cos.wh.yun.ccb.com/bucket）
    //    endpoint.isPrefixURL = NO;
    configuration.appID = appid;
    endpoint.serviceName = serviceName;
    configuration.endpoint = endpoint;
    configuration.signatureProvider = self;
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
    
    self.credentialFenceQueue = [QCloudCredentailFenceQueue new];
    self.credentialFenceQueue.delegate = self;
    
}

//第二步：实现QCloudSignatureProvider协议
- (void)signatureWithFields:(QCloudSignatureFields *)fileds
                    request:(QCloudBizHTTPRequest *)request
                 urlRequest:(NSMutableURLRequest *)urlRequst
                  compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock {
    //实现签名的过程，我们推荐在服务器端实现签名的过程，具体请参考接下来的 “生成签名” 这一章。
    
    /// 1、这里是本地签名，文档说：不推荐。
    /*
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = kQCloudSecretID;
    credential.secretKey = kQCloudSecretKey;
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
    QCloudSignature* signature =  [creator signatureForData:urlRequst];
    continueBlock(signature, nil);
    */
    
    /// 2、脚手架工具
    [self.credentialFenceQueue performAction:^(QCloudAuthentationCreator *creator, NSError *error) {
        if (error) {
            continueBlock(nil, error);
        } else {
            QCloudSignature* signature =  [creator signatureForData:urlRequst];
            continueBlock(signature, nil);
        }
    }];
}

// 上传时会走这里签名，签名完成后再走👆的协议
- (void)fenceQueue:(QCloudCredentailFenceQueue *)queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock {
    
    /// 获取临时签名信息
    NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
    NSDictionary *object = [udf objectForKey:@"tencentCloudTmpData"];
    
    NSLog(@"\n\n\nobject = %@",object);
    
    NSString *TmpSecretId = object[@"TmpSecretId"] ?:@"";
    NSString *TmpSecretKey = object[@"TmpSecretKey"] ?:@"";
    NSInteger NowTime = [(object[@"NowTime"] ?:@"") integerValue];
    NSInteger ExpiredTime = [(object[@"ExpiredTime"] ?:@"") integerValue];
    NSString *Token = object[@"Token"];
    
    QCloudCredential *credential = [QCloudCredential new];
    //在这里可以同步过程从服务器获取临时签名需要的secretID,secretKey,expiretionDate和token参数
    credential.secretID = TmpSecretId;
    credential.secretKey = TmpSecretKey;
    /*强烈建议返回服务器时间作为签名的开始时间，用来避免由于用户手机本地时间偏差过大导致的签名不正确 */
    credential.startDate = [NSDate dateWithTimeIntervalSince1970:NowTime];
    credential.experationDate = [NSDate dateWithTimeIntervalSince1970:ExpiredTime];
    credential.token = Token;
    
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
    continueBlock(creator, nil);
}




@end
