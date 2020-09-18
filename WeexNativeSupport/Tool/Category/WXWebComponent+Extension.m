//
//  WXWebComponent+Extension.m
//  WeexDemo
//
//  Created by 吴述雄 on 2018/11/15.
//  Copyright © 2018年 wusx. All rights reserved.
//

#import "WXWebComponent+Extension.h"
#import <objc/runtime.h>
#import "WeakScriptMessageDelegate.h"
@interface WXWebComponent ()<WKScriptMessageHandler>

@property (nonatomic) BOOL isBounces;

@end

@implementation WXWebComponent (Extension)

- (void)setIsBounces:(BOOL)isBounces {
    objc_setAssociatedObject(self, @selector(isBounces), @(isBounces), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isBounces {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

+ (void)load {
//    [self weex_swizzle:[self class] Method:@selector(initWithRef:type:styles:attributes:events:weexInstance:) withMethod:@selector(new_initWithRef:type:styles:attributes:events:weexInstance:)];
    [self weex_swizzle:[self class] Method:@selector(viewDidLoad) withMethod:@selector(new_viewDidLoad)];
//    [self weex_swizzle:[self class] Method:@selector(webView:shouldStartLoadWithRequest:navigationType:) withMethod:@selector(new_webView:shouldStartLoadWithRequest:navigationType:)];
//    [self weex_swizzle:[self class] Method:@selector(notifyWebview:) withMethod:@selector(new_notifyWebview:)];
//    [self weex_swizzle:[self class] Method:@selector(willMoveToParentViewController:) withMethod:@selector(new_willMoveToParentViewController:)];
}

- (void)new_viewDidLoad {
    [self new_viewDidLoad];
    WKWebViewConfiguration *configuration = ((WKWebView *)self.view).configuration;
    [configuration.userContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:@"callNative"];
    
    [(UIScrollView *)[[self.view subviews] objectAtIndex:0] setBounces:self.isBounces];
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
// 收到js消息
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"callNative"]) {
        [self fireEvent:@"notify" params:message.body];
    }
}
#pragma clang diagnostic pop

- (NSMutableDictionary<NSString *, id> *)baseInfo {
    WKWebView *webView = (WKWebView *)self.view;
    NSMutableDictionary<NSString *, id> *info = [NSMutableDictionary new];
    [info setObject:webView.URL.absoluteString ?: @"" forKey:@"url"];
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        [info setObject:result ? result : @"" forKey:@"title"];
    }];
    [info setObject:@(webView.canGoBack) forKey:@"canGoBack"];
    [info setObject:@(webView.canGoForward) forKey:@"canGoForward"];
    return info;
}


@end
