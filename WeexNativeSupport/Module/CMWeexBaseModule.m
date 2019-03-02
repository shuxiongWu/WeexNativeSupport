//
//  CMWeexBaseModule.m
//  WeexDemo
//
//  Created by 吴述雄 on 2019/2/22.
//  Copyright © 2019 wusx. All rights reserved.
//  基础功能例如打电话、短震、获取系统信息等

#import "CMWeexBaseModule.h"
#import <WeexSDK/WeexSDK.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <SVProgressHUD.h>

@implementation CMWeexBaseModule
@synthesize weexInstance;
WX_EXPORT_METHOD(@selector(getUUID:))

+ (void)load{
    [WXSDKEngine registerModule:@"BaseModule" withClass:[CMWeexBaseModule class]];
}

#pragma mark ---------------------获取UUID---------------------
- (void)getUUID:(WXKeepAliveCallback)callBack{
    //获取项目的bundle ID
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    //根据bundle ID拼接一个自定义的key用来作为keychain里面的唯一标示
    //    NSString *keyUUid = [NSString stringWithFormat:@"%@.uuid",bundleId];
    //将bundle ID作为唯一key在keychain里面获取保存的uuid
    NSString * strUUID = (NSString *)[self load:bundleId];
    
    //首次执行该方法时，uuid为空
    if ([strUUID isEqualToString:@""] || !strUUID)
    {
        //生成一个uuid的方法
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        
        //将该uuid保存到keychain
        [self save:bundleId data:strUUID];
    }
    if (callBack) {
        callBack(strUUID, YES);
    }
}

- (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}


- (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

- (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

#pragma mark ---------------------保存图片到相册---------------------
- (void)savePhotos:(NSArray *)array {
    
    __block BOOL fail = NO;
    __block NSInteger index = 0;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        //无权限
        [SVProgressHUD showInfoWithStatus:@"请先配置访问权限"];
        return;
    }
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *urlString = array[idx];
        if ([urlString containsString:@"http"]) {//网络地址
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:array[idx]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                __block ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
                [lib writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        fail = YES;
                    }
                    index ++;
                }];
            }];
        }else {//base64图片字符串
            NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:urlString options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
            UIImage *decodedImage = [UIImage imageWithData: decodeData];
            __block ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            [lib writeImageToSavedPhotosAlbum:decodedImage.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    fail = YES;
                }
                index ++;
            }];
        }
        
    }];
    
    if (index == array.count) {
        if (fail) {
            [SVProgressHUD showErrorWithStatus:@"保存失败"];
        }else {
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        }
    }
}

@end
