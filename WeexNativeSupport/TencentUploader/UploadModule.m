//
//  UploadModule.m
//  WeexDemo
//
//  Created by yMac on 2019/6/26.
//  Copyright © 2019 taobao. All rights reserved.
//

#import "UploadModule.h"
#import <WeexSDK/WeexSDK.h>
#import "HXPhotoPicker.h"
#import <SVProgressHUD.h>

#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <QCloudCore/QCloudCore.h>

#import "NSURL+FileExtension.h"
#import "WeexEncriptionHelper.h"
#import "ASCameraViewController.h"
#import <MJExtension.h>


/// 保存腾讯云存储临时签名信息
static NSString *tencentCloudTmpData = @"tencentCloudTmpData";

@interface UploadModule ()

@property (nonatomic, weak) QCloudCOSXMLUploadObjectRequest *uploadRequest;

@end

@implementation UploadModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(uploadVideo:callBack:))

+ (void)load {
    [WXSDKEngine registerModule:@"TencentCloud" withClass:[UploadModule class]];
}

- (void)uploadVideo:(NSDictionary *)params callBack:(WXModuleKeepAliveCallback)callBack {
    
    if (![params isKindOfClass:[NSDictionary class]]) {
        if (callBack) {
            NSDictionary *result = @{@"code":@(1), @"message":@"参数错误，请传入一个对象",@"data":@{}};
            callBack([result mj_JSONString],NO);
        }
        return;
    }
    if (!params[@"videoMaxDuration"]) {
        if (callBack) {
            NSDictionary *result = @{@"code":@(1), @"message":@"参数错误，没有videoMaxDuration",@"data":@{}};
            callBack([result mj_JSONString],NO);
        }
        return;
    }
    if (!params[@"tempSignatureData"] || ![params[@"tempSignatureData"] isKindOfClass:[NSDictionary class]]) {
        if (callBack) {
            NSDictionary *result = @{@"code":@(1), @"message":@"参数错误，没有tempSignatureData或类型不对",@"data":@{}};
            callBack([result mj_JSONString],NO);
        }
        return;
    }
    
    NSInteger videoMaxDuration = [params[@"videoMaxDuration"] integerValue];
    /// 保存临时签名信息
    NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
    [udf setObject:params[@"tempSignatureData"] forKey:tencentCloudTmpData];
    [udf synchronize];
    
    if ([params[@"openType"] isEqualToString:@"camera"]) {
        
        [self recordAVideo:videoMaxDuration callback:callBack];
    } else {
        
        [self selectVideoFromAlbum:videoMaxDuration callback:callBack];
    }
    
    
}


- (void)selectVideoFromAlbum:(NSInteger)videoMaxDuration callback:(WXKeepAliveCallback)callBack {
    
    HXPhotoManager *manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypeVideo];
    manager.configuration.saveSystemAblum = NO;
    manager.configuration.openCamera = NO;
    manager.configuration.themeColor = [UIColor blackColor];
    
    manager.configuration.videoMaxDuration = videoMaxDuration;
    [manager clearSelectedList];
    
    [weexInstance.viewController hx_presentAlbumListViewControllerWithManager:manager
                                                                         done:^(NSArray<HXPhotoModel *> *allList, NSArray<HXPhotoModel *> *photoList, NSArray<HXPhotoModel *> *videoList, NSArray<UIImage *> *imageList, BOOL original, HXAlbumListViewController *viewController) {
                                                                             
                                                                             [SVProgressHUD showWithStatus:@"视频上传中…"];
                                                                             HXPhotoModel *model = [videoList firstObject];
                                                                             if ([model.avAsset isKindOfClass:[AVComposition class]]) {
                                                                                 /// 慢动作视频
                                                                                 [SVProgressHUD showErrorWithStatus:@"不支持慢动作视频！"];
                                                                                 
                                                                                 NSDictionary *result = @{@"code":@(1), @"message":@"不支持慢动作视频！",@"data":@{}};
                                                                                 if (callBack) {
                                                                                     callBack([result mj_JSONString],YES);
                                                                                 }
                                                                                 return;
                                                                             }
                                                                             if (![model.avAsset isKindOfClass:[AVAsset class]]) {
                                                                                 /// 防止崩溃。
                                                                                 [SVProgressHUD showErrorWithStatus:@"未知的视频格式"];
                                                                                 NSDictionary *result = @{@"code":@(1), @"message":@"未知的视频格式",@"data":@{}};
                                                                                 if (callBack) {
                                                                                     callBack([result mj_JSONString],YES);
                                                                                 }
                                                                                 return;
                                                                             }
                                                                             NSURL *videoUrl = [model.avAsset valueForKey:@"URL"];
                                                                             NSLog(@"%@",videoUrl);
                                                                             
                                                                             [self zipVideoWithInputURL:videoUrl completeBlock:^(NSURL *outputUrl) {
                                                                                 
                                                                                 [self uploadFile:outputUrl callBack:callBack];
                                                                             }];
                                                                             
                                                                             
                                                                         } cancel:^(HXAlbumListViewController *viewController) {
                                                                             if (callBack) {
                                                                                 NSDictionary *result = @{@"code":@(1), @"message":@"用户取消选择视频",@"data":@{}};
                                                                                 callBack([result mj_JSONString],NO);
                                                                             }
                                                                         }];
}

- (void)recordAVideo:(NSInteger)videoMaxDuration callback:(WXKeepAliveCallback)callBack {
    
    NSString *bundlePath = [[NSBundle mainBundle]pathForResource: @"HXPhotoPicker"ofType:@"bundle"];
    NSBundle *resourceBundle =[NSBundle bundleWithPath:bundlePath];
    ASCameraViewController *cameraVC = [resourceBundle loadNibNamed:@"ASCameraViewController" owner:self
                                                            options:nil].lastObject;
    cameraVC.ASSeconds = videoMaxDuration;//设置可录制最长时间
    [cameraVC setTakeBlock:^(id item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"视频上传中..."];
        });
        NSURL *videoURL = item;
        [self zipVideoWithInputURL:videoURL completeBlock:^(NSURL * url) {
            
            [self uploadFile:url callBack:callBack];
        }];
    }];
    [weexInstance.viewController presentViewController:cameraVC animated:YES completion:nil];
}


/// 上传到腾讯云
- (void)uploadFile:(NSURL *)url callBack:(WXKeepAliveCallback)callBack {
    
    /// 获取视频封面图
    UIImage *preViewImage = [self getVideoPreViewImage:url];
    NSString *base64String = [WeexEncriptionHelper encodeBase64WithData:UIImageJPEGRepresentation(preViewImage, 0.5)];
    
    NSDictionary *tmpData = [[NSUserDefaults standardUserDefaults] objectForKey:tencentCloudTmpData];
    
    QCloudCOSXMLUploadObjectRequest* upload = [QCloudCOSXMLUploadObjectRequest new];
    upload.body = url;
    upload.bucket = tmpData[@"Bucket"] ?: @"";
    
    upload.object = [NSString stringWithFormat:@"%@%@.mp4",tmpData[@"Path"] ?: @"",[UploadModule getTimestamp]];
    
    _uploadRequest = upload;
    __weak typeof(self) weakSelf = self;
    NSDate *beforeUploadDate = [NSDate date];
    //    unsigned long long fileSize = [(NSURL*)upload.body fileSizeInContent];
    NSString *fileSizeDescription =  [(NSURL*)upload.body fileSizeWithUnit];
    double fileSizeSmallerThan1024 = [(NSURL*)upload.body fileSizeSmallerThan1024];
    NSString *fileSizeCount = [(NSURL*)upload.body fileSizeCount];
    NSString *object = upload.object;
    [upload setFinishBlock:^(QCloudUploadObjectResult *result, NSError * error) {
        weakSelf.uploadRequest = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            
            if (error) {
                
                if (callBack) {
                    NSDictionary *result = @{@"code":@(1), @"message":@"上传失败",@"data":@{}};
                    callBack([result mj_JSONString],NO);
                }
                //                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                NSLog(@"\n=====================================%@",error.localizedDescription);
                //                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            } else {
                NSDate *afterUploadDate = [NSDate date];
                NSTimeInterval uploadTime = [afterUploadDate timeIntervalSinceDate:beforeUploadDate];
                NSMutableString *resultImformationString = [[NSMutableString alloc] init];
                [resultImformationString appendFormat:@"上传耗时:%.1f 秒\n\n",uploadTime];
                [resultImformationString appendFormat:@"文件大小: %@\n\n",fileSizeDescription];
                [resultImformationString appendFormat:@"上传速度:%.2f %@/s\n\n",fileSizeSmallerThan1024/uploadTime,fileSizeCount];
                [resultImformationString appendFormat:@"下载链接:%@\n\n",result.location];
                
                if (result.__originHTTPURLResponse__) {
                    [resultImformationString appendFormat:@"返回HTTP头部:\n%@\n",result.__originHTTPURLResponse__.allHeaderFields];
                }
                
                if (result.__originHTTPResponseData__) {
                    [resultImformationString appendFormat:@"返回HTTP Body内容:\n%@\n",[[NSString alloc] initWithData:result.__originHTTPResponseData__ encoding:NSUTF8StringEncoding]];
                }
                
                NSLog(@"\n\n\nobject = %@",object);
                NSLog(@"\n\n\n%@\n\n\n",resultImformationString);
                
                if (callBack) {
                    //                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    //                    pasteboard.string = result.location;
                    //                    [SVProgressHUD showSuccessWithStatus:@"上传至腾讯云成功，下载地址已添加到剪切板，复制至网页查看"];
                    
                    NSDictionary *result = @{@"code":@(0), @"message":@"上传成功",@"data":@{@"videoUrl":object,@"image":base64String}};
//                    NSLog(@"\n\n\n\nresult = %@",result);
                    callBack([result mj_JSONString],YES);
                } else {
                    //                    [SVProgressHUD showErrorWithStatus:@"callback没有调用"];
                    //                    NSLog(@"===============================================callback没有调用");
                }
                
            }
        });
    }];
    
    [upload setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //            NSLog(@"bytesSent: %lli, totoalBytesSent %lli ,totalBytesExpectedToSend: %lli ",bytesSent,totalBytesSent,totalBytesExpectedToSend);
        });
    }];
    
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:upload];
}

/// 视频压缩转换
- (void)zipVideoWithInputURL:(NSURL*)inputURL
               completeBlock:(void (^)(NSURL *outputUrl))completeBlock {
    
    NSURL *newVideoUrl ; //一般.mp4
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    newVideoUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output%@.mp4",[formater stringFromDate:[NSDate date]]]];//这个是保存在app自己的沙盒路径里，后面可以选择是否在上传后删除掉。我建议删除掉，免得占空间。
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    /// 视频压缩等级
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
    //  NSLog(resultPath);
    exportSession.outputURL = newVideoUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:{
                 NSLog(@"AVAssetExportSessionStatusCompleted");
                 //NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:outputURL]]);
                 //NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[outputURL path]]]);
                 
                 //UISaveVideoAtPathToSavedPhotosAlbum([outputURL path], self, nil, NULL);//这个是保存到手机相册
                 
                 //[self alertUploadVideo:outputURL];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (completeBlock) {
                         completeBlock(newVideoUrl);
                     }
                 });
                 break;
             }
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     if (completeBlock) {
                         completeBlock(nil);
                     }
                 });
                 
                 break;
         }
         
     }];
    
}

+ (NSString *)getTimestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
    
}

// 获取视频第一帧
- (UIImage*)getVideoPreViewImage:(NSURL *)path {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

@end
