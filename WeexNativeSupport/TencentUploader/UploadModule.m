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
#import <SVProgressHUD/SVProgressHUD.h>

#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <QCloudCore/QCloudCore.h>

#import "NSURL+FileExtension.h"
#import "WeexEncriptionHelper.h"
#import "ASCameraViewController.h"
#import <MJExtension/MJExtension.h>


/// 保存腾讯云存储临时签名信息
static NSString *tencentCloudTmpData = @"tencentCloudTmpData";

@interface UploadModule ()

@property (nonatomic, weak) QCloudCOSXMLUploadObjectRequest *uploadRequest;
// 视频质量，默认高
@property (nonatomic, copy) NSString *videoQuality;

@end

@implementation UploadModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(uploadVideo:callBack:))
WX_EXPORT_METHOD(@selector(uploadImage:callback:))

+ (void)load {
    [WXSDKEngine registerModule:@"TencentCloud" withClass:[UploadModule class]];
}

- (void)uploadImage:(id)params callback:(WXModuleKeepAliveCallback)callback {
    
    if ([params isKindOfClass:[NSString class]]) {
        params = [params mj_JSONObject];
    }
    
    NSMutableDictionary *mdic = [[NSMutableDictionary alloc] initWithDictionary:params[@"tempSignatureData"]];
    
    // 腾讯云工单结果：这种方式后去临时签名，会有一层缓存，只要秘钥没过期，就会一直用该临时秘钥，建议您需要用秘钥的时候，直接在signatrue去申请，不用这里的栅栏机制
    
    // ExpiredTime
    // 在ExpiredTime有效期内只会调用一次脚手架的签名；这时候如果后台存储桶发生改变并且重新签名，而这里没有调用脚手架重新签名（用的旧签名），就会导致403错误
    // TODO: 暂时的处理方法
    // 验证了一下，这里修改ExpiredTime暂时来说并不会对使用有什么影响
    NSInteger ExpiredTime = [[UploadModule getTimestamp] integerValue] + 5;
    [mdic setObject:[NSString stringWithFormat:@"%ld",ExpiredTime] forKey:@"ExpiredTime"];
    
    /// 保存临时签名信息
    NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
    [udf setObject:mdic forKey:tencentCloudTmpData];
    [udf synchronize];
    
    NSString *fileUrl = [self saveToSandbox:params[@"base64String"] fileUrl:params[@"fileUrl"]];
    if (fileUrl) {
//            NSLog(@"保存成功");
        [self _uploadImage:fileUrl callback:callback];
    } else {
//            NSLog(@"保存失败");
        if (callback) {
            callback([@{@"code":@"1",@"message":@"图片保存失败"} mj_JSONString],YES);
        }
    }
    
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
    
    self.videoQuality = params[@"videoQuality"] ? : AVAssetExportPresetHighestQuality;
    
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
                                                                             [SVProgressHUD setMinimumDismissTimeInterval:300];
                                                                             [SVProgressHUD showWithStatus:@"视频上传中..."];
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
                                                                                 
                                                                                 if (outputUrl) {
                                                                                     [self uploadFile:outputUrl callBack:callBack];
                                                                                 } else {
                                                                                     if (callBack) {
                                                                                         NSDictionary *result = @{@"code":@(1), @"message":@"视频压缩失败，请检查参数",@"data":@{}};
                                                                                         callBack([result mj_JSONString],NO);
                                                                                     }
                                                                                 }
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
            [SVProgressHUD setMinimumDismissTimeInterval:300];
            [SVProgressHUD showWithStatus:@"视频上传中..."];
        });
        NSURL *videoURL = item;
        [self zipVideoWithInputURL:videoURL completeBlock:^(NSURL * url) {
            
            if (url) {
                [self uploadFile:url callBack:callBack];
            } else {
                if (callBack) {
                    NSDictionary *result = @{@"code":@(1), @"message":@"视频压缩失败，请检查参数",@"data":@{}};
                    callBack([result mj_JSONString],NO);
                }
            }
        }];
    }];
    [weexInstance.viewController presentViewController:cameraVC animated:YES completion:nil];
}

- (void)_uploadImage:(NSString *)fileUrl callback:(WXModuleKeepAliveCallback)callback {
    
    NSDictionary *tmpData = [[NSUserDefaults standardUserDefaults] objectForKey:tencentCloudTmpData];
    QCloudCOSXMLUploadObjectRequest *upload = [QCloudCOSXMLUploadObjectRequest new];
    upload.body = [NSURL URLWithString:fileUrl];
    upload.bucket = tmpData[@"Bucket"] ?: @"";
    upload.object = [NSString stringWithFormat:@"%@%@.jpg",tmpData[@"Path"] ?: @"",[UploadModule getTimestamp]];
    
    NSDate *beforeUploadDate = [NSDate date];
    NSString *fileSizeDescription =  [(NSURL*)upload.body fileSizeWithUnit];
    double fileSizeSmallerThan1024 = [(NSURL*)upload.body fileSizeSmallerThan1024];
    NSString *fileSizeCount = [(NSURL*)upload.body fileSizeCount];
    NSString *object = upload.object;
    
    [upload setFinishBlock:^(QCloudUploadObjectResult *result, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (fileUrl.length > 7) {
                NSString *filePath = [fileUrl substringFromIndex:7];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
            }
            if (error) {
                
                if (callback) {
                    NSDictionary *result = @{@"code":@(1),@"message":@"上传失败",@"fileUrl":fileUrl,@"data":@{}};
                    callback([result mj_JSONString],NO);
                }
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
                NSLog(@"%@",resultImformationString);
                if (callback) {
                    NSDictionary *resultDic = @{@"code":@(0),@"message":@"上传成功",@"fileUrl":fileUrl,@"data":@{@"imageUrl":object,@"fullImageUrl":result.location}};
                    callback([resultDic mj_JSONString],YES);
                }
                
            }
        });
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:upload];
}

/// 上传到腾讯云
- (void)uploadFile:(NSURL *)url callBack:(WXKeepAliveCallback)callBack {
    
    /// 获取视频封面图
    UIImage *preViewImage = [self getVideoPreViewImage:url];
    NSString *base64String = [WeexEncriptionHelper encodeBase64WithData:[self compressImageQuality:preViewImage toByte:500*1024]];
    
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
            //删除沙盒文件
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:url.absoluteString]) {
                [fileManager removeItemAtPath:url.absoluteString error:nil];
            }
            
            if (error) {
                
                if (callBack) {
                    NSDictionary *result = @{@"code":@(1), @"message":@"上传失败",@"data":@{}};
                    callBack([result mj_JSONString],NO);
                }
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
                
//                NSLog(@"\n\n\nobject = %@",object);
//                NSLog(@"\n\n\n%@\n\n\n",resultImformationString);
                
                if (callBack) {
                    //                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    //                    pasteboard.string = result.location;
                    //                    [SVProgressHUD showSuccessWithStatus:@"上传至腾讯云成功，下载地址已添加到剪切板，复制至网页查看"];
                    
                    NSDictionary *resultDic = @{@"code":@(0), @"message":@"上传成功",@"data":@{@"videoUrl":object,@"fullVideoUrl":result.location,@"image":base64String}};
                    callBack([resultDic mj_JSONString],YES);
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
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:self.videoQuality];
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

/// 存储图片到沙盒
- (NSString *)saveToSandbox:(NSString *)base64String fileUrl:(NSString *)fileUrl {
    UIImage *ori_image;
    if (base64String) {
        ori_image = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters]];
    } else if (fileUrl) {
        ori_image = [UIImage imageWithContentsOfFile:fileUrl];
    } else {
        // 没有else的啦
        return nil;
    }
    
    UIImage *image = [self zipImageWithImage:ori_image];
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/images"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:savePath]) {
        [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[UploadModule getTimestamp]];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/images/%@",fileName]];
    
    if ([UIImageJPEGRepresentation(image,1.0) writeToFile:filePath atomically:YES]) {
        return [NSString stringWithFormat:@"file://%@",filePath];
    } else {
        return nil;
    }
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

/**
 压图片质量
 @param image image
 @return Data
 */
- (UIImage *)zipImageWithImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
//    CGFloat maxFileSize = 500*1024;
//    CGFloat compression = 1.0f;
//    NSData *compressedData = UIImageJPEGRepresentation(image, compression);
//
////    double oriDataLength = [compressedData length] * 1.0;
//    while ([compressedData length] > maxFileSize) {
//        compression *= 0.9;
//        compressedData = UIImageJPEGRepresentation([self compressImage:image newWidth:image.size.width*compression], compression);
//    }
    // 压缩下来大概有1.5M左右，前提是选照片的时候要选原图，不然拿到高清图在那压也没用
    NSData *compressedData = [self compressImageQuality:image toByte:500*1024];
    // 计算大小
//    double dataLength = [compressedData length] * 1.0;
//    NSArray *typeArray = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB",@"ZB",@"YB"];
//    NSInteger index = 0;
//    while (dataLength > 1024) {
//        dataLength /= 1024.0;
//        index ++;
//    }
//    NSInteger oriIndex = 0;
//    while (oriDataLength > 1024) {
//        oriDataLength /= 1024.0;
//        oriIndex ++;
//    }
//
//    NSLog(@"oriImage大小 = %.3f %@",oriDataLength,typeArray[index]);
//    NSLog(@"image大小 = %.3f %@",dataLength,typeArray[index]);
    
    UIImage *result = [UIImage imageWithData:compressedData];
    return result;
}

/**
 *  等比缩放本图片大小
 *
 *  @param newImageWidth 缩放后图片宽度，像素为单位
 *
 *  @return self-->(image)
 */
- (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth
{
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = newImageWidth;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}


/// 获取视频第一帧
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

/// 视频压缩到指定大小
- (NSData *)compressImageQuality:(UIImage *)image toByte:(NSInteger)maxLength {
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    //UIImage *resultImage = [UIImage imageWithData:data];
    return data;
}

@end
