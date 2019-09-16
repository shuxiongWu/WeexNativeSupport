//
//  FileModule.m
//  WeexDemo
//
//  Created by yMac on 2019/8/22.
//  Copyright © 2019 taobao. All rights reserved.
//

#import "FileModule.h"
#import <AFNetworking.h>
#import <SSZipArchive.h>

@implementation FileModule
WX_EXPORT_METHOD(@selector(getJsPath:callback:))
WX_EXPORT_METHOD(@selector(setUpdateInfo:))

+ (void)load {
    [WXSDKEngine registerModule:@"FileModule" withClass:[FileModule class]];
}

/**
 热更新说明：
 
 App版本号 x.x.x
 服务器返回的版本号 x.x.x.x : 最后一位 作为热更新版本号 0表示无需热更新
 
 当前如果检测到App Store有新版本，则将本地的热更新版本号归零，不做任何操作
 当前如果是App Store最新版本，本地热更新版本号 和 服务器热更新版本号做比较 再进行更新操作
 
 当前如果是App Store最新版本，并且没有热更新版本，需要将旧的资源包清除（如果有的话）
 
 */

/**
 获取更新信息
 */
- (void)setUpdateInfo:(NSDictionary *)data {
    
    //NSLog(@"update info = %@",data);
    
    if (!data || ![data isKindOfClass:NSDictionary.class]) {
        return;
    }
    
    NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
    
    NSString *newVersion = data[@"version"]?:@"";
    NSString *hotVersion = @"0";
    NSString *url = data[@"url"];
    
    NSString *hotupdate_status = @"0";
    if (data[@"hotupdate_status"] && [data[@"hotupdate_status"] isKindOfClass:[NSString class]]) {
        hotupdate_status = data[@"hotupdate_status"];
    }
    
    //获取本地软件的版本号 x.x.x
    NSString *localVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if ([newVersion isKindOfClass:[NSString class]] && [newVersion containsString:@"."]) {
        NSArray *serverVersionArr = [newVersion componentsSeparatedByString:@"."];
        
        if (serverVersionArr.count == 4) {
            hotVersion = [serverVersionArr lastObject];
            /// 取App Store版本号
            serverVersionArr = [serverVersionArr subarrayWithRange:NSMakeRange(0, 3)];
        }
        
        /// 和App Store的版本是否相同
        BOOL isAppStoreEqual = [[serverVersionArr componentsJoinedByString:@"."] isEqualToString:localVersion];
        
        if (isAppStoreEqual) {
            //NSLog(@"isAppStoreEqual = YES");
            /// 只有当App Store版本号和服务器上的版本号一致的时候才进行热更新判断操作
            /// 文件保存路径
            NSString *resourcePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Resources"];
            /// 异常处理
            if ([hotupdate_status isEqualToString:@"-1"]) {
                [self clearResourcesAtPath:resourcePath];
                /// 记录热更新版本号
                [udf setObject:hotVersion forKey:@"hotVersion"];
                [udf synchronize];
                return;
            }
            
            NSInteger currentHotVersion = [[udf objectForKey:@"hotVersion"]?:@"0" integerValue];
            NSInteger serverHotVersion = hotVersion.integerValue;
            if (serverHotVersion == 0) {
                /// 当前是App Store最新版本，并且没有热更新版本，需要将旧的资源包清除
                [self clearResourcesAtPath:resourcePath];
                /// 如果用户在没有打开App的情况下直接更新App，也得要清零
                [udf setObject:@"0" forKey:@"hotVersion"];
                [udf synchronize];
                return;
            }
            /// 当前热更新版本号落后
            if (url && (serverHotVersion > currentHotVersion)) {
                [self downloadResources:url hotVersion:hotVersion];
            }
            
        } else {
            //NSLog(@"isAppStoreEqual = NO");
            /// 和App Store的版本不相同，不进行操作，本地的热更新版本号归0
            [udf setObject:@"0" forKey:@"hotVersion"];
            [udf synchronize];
        }
    }
    
}

- (void)downloadResources:(NSString *)urlString hotVersion:(NSString *)hotVersion {
    
    NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *resourcePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Resources"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:resourcePath]) {
        NSError *error;
        [fileManager createDirectoryAtPath:resourcePath withIntermediateDirectories:YES attributes:nil error:&error];
        //NSLog(@"创建文件夹: %@",error?error.localizedDescription:@"创建Resources文件夹成功");
    } else {
        //NSLog(@"Resources文件夹已存在");
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 下载地址的完整地址
    NSString *fullFilePath = [documentPath stringByAppendingPathComponent:url.lastPathComponent];
    
    if ([fileManager fileExistsAtPath:fullFilePath]) {
        [fileManager removeItemAtPath:fullFilePath error:nil];
    }
    
    //NSLog(@"filePath = %@",fullFilePath);
    
    /* 创建网络下载对象 */
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //如果需要进行UI操作，需要获取主线程进行操作
        });
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:fullFilePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //NSLog(@"下载完成");
        if ([url.lastPathComponent hasSuffix:@".zip"]) {
            
            /// 清除旧文件
            [self clearResourcesAtPath:resourcePath];
            
            /// 解压到Resources
            BOOL isSuccess = [SSZipArchive unzipFileAtPath:fullFilePath toDestination:resourcePath];
            //NSLog(@"解压%@",isSuccess?@"成功":@"失败");
            if (isSuccess) {
                //保存热更新版本号
                NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
                [udf setObject:hotVersion forKey:@"hotVersion"];
                [udf synchronize];
                
                /// 移除.zip文件
                NSError *error;
                [fileManager removeItemAtPath:fullFilePath error:&error];
                if (error) {
                    //NSLog(@"移除失败");
                }
                //NSLog(@"解压完成，Resources下的文件：%@",[fileManager contentsOfDirectoryAtPath:resourcePath error:nil]);
            }
        } else {
            //NSLog(@"不是压缩文件");
        }
    }];
    [downloadTask resume];
}

/**
 删除所有文件
 */
- (void)clearResourcesAtPath:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:nil];
    //NSLog(@"contents = %@",contents);
    if (contents.count == 0) {
        return;
    }
    NSEnumerator *e = [contents objectEnumerator];
    NSString *fileName;
    while (fileName = [e nextObject]) {
        //NSLog(@"fileName = %@",fileName);
        NSError *error;
        [fileManager removeItemAtPath:[path stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]] error:&error];
        if (error) {
            //NSLog(@"删除失败：%@",error.localizedDescription);
        }
    }
    contents = [fileManager contentsOfDirectoryAtPath:path error:nil];
    //NSLog(@"删除后的contents = %@",contents);
    
}

/**
 获取完整的js文件地址
 @param suffix @"/folder/file_name.js"
 */
- (void)getJsPath:(NSString *)suffix callback:(WXModuleCallback)callback {
    
    NSString *document_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Resources"];
    NSString *full_path = [NSString stringWithFormat:@"%@%@",document_path,suffix];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:full_path]) {
        
        if (callback) {
            callback([NSString stringWithFormat:@"file://%@",full_path]);
        }
    } else {
        
        full_path = [NSString stringWithFormat:@"file://%@/bundlejs%@",[NSBundle mainBundle].bundlePath,suffix];
        if (callback) {
            callback(full_path);
        }
    }
    //NSLog(@"full_path = %@",full_path);
}
@end
