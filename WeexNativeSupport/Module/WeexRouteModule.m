//
//  WeexRouteModule.m
//  WeexDemo
//
//  Created by 吴述雄 on 2019/1/18.
//  Copyright © 2019 wusx. All rights reserved.
//

#import "WeexRouteModule.h"
#import <WeexSDK/WeexSDK.h>
#import "WXDemoViewController.h"
#import <WeexSDK/WeexSDK.h>
@implementation WeexRouteModule
@synthesize weexInstance;
WX_EXPORT_METHOD(@selector(presentWithParams:))
WX_EXPORT_METHOD(@selector(dismissWithParams:))
+ (void)load{
    [WXSDKEngine registerModule:@"WeexRouterModule" withClass:[WeexRouteModule class]];
}

- (void)presentWithParams:(NSDictionary *)params{
    UIViewController *demo = [[WXDemoViewController alloc] init];
    ((WXDemoViewController *)demo).url = [NSURL URLWithString:params[@"url"]];
    WXRootViewController *root = [[WXRootViewController alloc] initWithRootViewController:demo];
    root.modalPresentationStyle = UIModalPresentationFullScreen;
    [weexInstance.viewController presentViewController:root animated:[params[@"animate"] boolValue] ?: NO completion:nil];
}

- (void)dismissWithParams:(NSDictionary *)params {
    [weexInstance.viewController dismissViewControllerAnimated:[params[@"animate"] boolValue] ? [params[@"animate"] boolValue] : YES completion:nil];

}

@end
