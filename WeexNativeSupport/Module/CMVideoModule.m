//
//  CMVideoModule.m
//  WeexDemo
//
//  Created by 吴述雄 on 2019/2/20.
//  Copyright © 2019 wusx. All rights reserved.
//

#import "CMVideoModule.h"
#import <WeexSDK/WeexSDK.h>
#import "ASCameraViewController.h"
#import "NIMKitFileLocationHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVFoundation.h>
#import "WeexEncriptionHelper.h"
#import "HXPhotoPicker.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>

#define Timeout 30
@interface CMVideoModule ()<HXAlbumListViewControllerDelegate>
typedef void (^SuccesslBlock)(NSURLSessionDataTask *task, NSDictionary *respone);
typedef void (^FailureBlock)(NSURLSessionDataTask *task, NSError* error);
@property (strong, nonatomic) HXPhotoManager *manager;

@end
@implementation CMVideoModule
@synthesize weexInstance;
WX_EXPORT_METHOD(@selector(videoRecordingAndUploadWithParams:callBack:))
WX_EXPORT_METHOD(@selector(selectVideoFromPhotoAlbumAndUploadWithParams:callBack:))

static AFHTTPSessionManager *netWorkManager;
- (AFHTTPSessionManager *)netWorkManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        netWorkManager = [[AFHTTPSessionManager alloc] init];
        netWorkManager.requestSerializer =  [AFHTTPRequestSerializer serializer];
        netWorkManager.requestSerializer.timeoutInterval = Timeout;//请求超时
        //      manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy; //缓存策略
        netWorkManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];//支持类型
        
    });
    return netWorkManager;
}
+ (void)load{
    [WXSDKEngine registerModule:@"VideoModule" withClass:[CMVideoModule class]];
}

- (void)videoRecordingAndUploadWithParams:(NSDictionary *)params callBack:(WXKeepAliveCallback)callBack{
    NSString *bundlePath = [[NSBundle mainBundle]pathForResource: @"HXPhotoPicker"ofType:@"bundle"];
    NSBundle *resourceBundle =[NSBundle bundleWithPath:bundlePath];
    ASCameraViewController *cameraVC = [resourceBundle loadNibNamed:@"ASCameraViewController" owner:self
                         options:nil].lastObject;
//    ASCameraViewController *cameraVC = [[ASCameraViewController alloc] initWithNibName:@"ASCameraViewController" bundle:nil];
    cameraVC.ASSeconds = [params[@"seconds"] integerValue];//设置可录制最长时间
    self.manager.configuration.videoMaximumDuration = [params[@"seconds"] integerValue];
    [cameraVC setTakeBlock:^(id item) {
        [SVProgressHUD showWithStatus:@"视频上传中…"];
        NSURL *videoURL = item;
        UIImage *preViewImage = [self getVideoPreViewImage:videoURL];
        NSString *base64String = [WeexEncriptionHelper encodeBase64WithData:UIImageJPEGRepresentation(preViewImage, 0.5)];
        [self zipVideoWithInputURL:videoURL completeBlock:^(NSURL * url) {
            NSData *data = [NSData dataWithContentsOfURL:url];
            [self uploadVideoTodataBaseWithUrl:params[@"url"] parameters:@{
                                                                           @"img":base64String
                                                                           } videoData:data success:^(NSURLSessionDataTask *task, NSDictionary *respone) {
                if (callBack) {
                    callBack(respone ,YES);
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (callBack) {
                    callBack(@{} ,YES);
                }
            }];
        }];
    }];
    [weexInstance.viewController presentViewController:cameraVC animated:YES completion:nil];
}

- (void)selectVideoFromPhotoAlbumAndUploadWithParams:(NSDictionary *)params callBack:(WXKeepAliveCallback)callBack {
    self.manager.configuration.videoMaxDuration = [params[@"seconds"] integerValue];
    [self.manager clearSelectedList];
    [weexInstance.viewController hx_presentAlbumListViewControllerWithManager:self.manager done:^(NSArray<HXPhotoModel *> *allList, NSArray<HXPhotoModel *> *photoList, NSArray<HXPhotoModel *> *videoList, NSArray<UIImage *> *imageList, BOOL original, HXAlbumListViewController *viewController) {
        __block NSURL *videoUrl = nil;
        [SVProgressHUD showWithStatus:@"视频上传中…"];
        HXPhotoModel *model = [videoList firstObject];
        switch (model.type) {
            case HXPhotoModelMediaTypeVideo:{
                videoUrl = [model.avAsset valueForKey:@"URL"];
                UIImage *preViewImage = [self getVideoPreViewImage:videoUrl];
                NSString *base64String = [WeexEncriptionHelper encodeBase64WithData:UIImageJPEGRepresentation(preViewImage, 0.5)];
                [self zipVideoWithInputURL:model.fileURL completeBlock:^(NSURL * url) {
                    NSData *data = [NSData dataWithContentsOfURL:url?:videoUrl];
                    if (!data) {
                        [SVProgressHUD showErrorWithStatus:@"发生了预期之外的错误~"];
                        if (callBack) {
                            callBack(@{},YES);
                        }
                        return;
                    }
                    [self uploadVideoTodataBaseWithUrl:params[@"url"] parameters:@{
                                                                                   @"img":base64String
                                                                                   } videoData:data success:^(NSURLSessionDataTask *task, NSDictionary *respone) {
                        if (callBack) {
                            callBack(respone ,YES);
                        }
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        if (callBack) {
                            callBack(@{},YES);
                        }
                    }];


                }];
            }
                break;
            case HXPhotoModelMediaTypeCameraVideo:{
                NSData *data = [NSData dataWithContentsOfURL:model.videoURL];
                NSString *base64String = [WeexEncriptionHelper encodeBase64WithData:data];
                
                if (callBack) {
                    callBack(@[base64String],YES);
                }
            }
                break;
            default:
                if (callBack) {
                    callBack(@[@""],YES);
                }
                NSLog(@"我是默认类型");
                break;
        }

    } cancel:^(HXAlbumListViewController *viewController) {
        
    }];
}

- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypeVideo];
        _manager.configuration.saveSystemAblum = NO;
        _manager.configuration.openCamera = NO;
        _manager.configuration.themeColor = [UIColor blackColor];
        
    }
    return _manager;
}

- (void)zipVideoWithInputURL:(NSURL*)inputURL
                completeBlock:(void (^)(NSURL *))completeBlock
{
    
    NSURL *newVideoUrl ; //一般.mp4
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    newVideoUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output%@.mp4",[formater stringFromDate:[NSDate date]]]] ;//这个是保存在app自己的沙盒路径里，后面可以选择是否在上传后删除掉。我建议删除掉，免得占空间。
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
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


- (void)uploadVideoTodataBaseWithUrl:(NSString *)urlString parameters:(NSDictionary *)params videoData:(NSData *)videoData success:(SuccesslBlock)success failure:(FailureBlock)failure{
    
    NSString *url = [NSString stringWithFormat:@"%@?file=""",urlString];
    self.netWorkManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self.netWorkManager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //使用日期生成视频名称
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *fileName = [NSString stringWithFormat:@"%@.mp4",[formatter stringFromDate:[NSDate date]]];
        [formData appendPartWithFileData:videoData name:@"file" fileName:fileName mimeType:@"video/mp4"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //打印上传进度
        //CGFloat progress = 100.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *receiveStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSData * datas = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingMutableLeaves error:nil];
        
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
            success(task, jsonDict);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            [SVProgressHUD showSuccessWithStatus:@"上传失败"];
            failure(task, error);
        }
    }];
}

// 获取视频第一帧
- (UIImage*)getVideoPreViewImage:(NSURL *)path
{
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
