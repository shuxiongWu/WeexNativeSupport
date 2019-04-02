//
//  WXWebComponent+Extension.m
//  WeexDemo
//
//  Created by 吴述雄 on 2018/11/15.
//  Copyright © 2018年 wusx. All rights reserved.
//

#import "WXWebComponent+Extension.h"
#import <objc/runtime.h>
@interface WXWebComponent ()

@property (nonatomic) BOOL notifyEvent;

@property (nonatomic) BOOL isBounces;

@property (nonatomic) NSArray *urlInterceptArray;

@end

@implementation WXWebComponent (Extension)

- (void)setNotifyEvent:(BOOL)notifyEvent {
    objc_setAssociatedObject(self, @selector(notifyEvent), @(notifyEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)notifyEvent {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsBounces:(BOOL)isBounces {
    objc_setAssociatedObject(self, @selector(isBounces), @(isBounces), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isBounces {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setUrlInterceptArray:(NSArray *)urlInterceptArray {
    objc_setAssociatedObject(self, @selector(urlInterceptArray), urlInterceptArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSArray *)urlInterceptArray {
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)load {
    [self weex_swizzle:[self class] Method:@selector(initWithRef:type:styles:attributes:events:weexInstance:) withMethod:@selector(new_initWithRef:type:styles:attributes:events:weexInstance:)];
    [self weex_swizzle:[self class] Method:@selector(viewDidLoad) withMethod:@selector(new_viewDidLoad)];
    [self weex_swizzle:[self class] Method:@selector(webView:shouldStartLoadWithRequest:navigationType:) withMethod:@selector(new_webView:shouldStartLoadWithRequest:navigationType:)];
    
    [self weex_swizzle:[self class] Method:@selector(notifyWebview:) withMethod:@selector(new_notifyWebview:)];
    [self weex_swizzle:[self class] Method:@selector(webViewDidFinishLoad:) withMethod:@selector(new_webViewDidFinishLoad:)];
}

- (void)new_notifyWebview:(NSDictionary *)data {
    NSString *json = [WXUtility JSONString:data];
    NSString *code = [NSString stringWithFormat:@"(function(){var evt=null;var data=%@;if(typeof CustomEvent==='function'){evt=new CustomEvent('notify',{detail:data})}else{evt=document.createEvent('CustomEvent');evt.initCustomEvent('notify',true,true,data)}document.dispatchEvent(evt)}())", json];
    /// 解决[_jsContext evaluateScript:code];导致的崩溃问题
    [(UIWebView *)self.view stringByEvaluatingJavaScriptFromString:code];
}

-(instancetype)new_initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance {
    id ret = [self new_initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    
    self.notifyEvent = [attributes[@"notifyEvent"] boolValue];
    self.isBounces = [attributes[@"isBounces"] boolValue];
    self.urlInterceptArray = attributes[@"urlInterceptArray"];
    return ret;
}

- (void)new_viewDidLoad {
    [self new_viewDidLoad];
    
    [(UIScrollView *)[[self.view subviews] objectAtIndex:0] setBounces:self.isBounces];
}

- (BOOL)new_webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    for (NSInteger i = 0; i < self.urlInterceptArray.count; i ++) {
        if ([request.URL.absoluteString containsString:self.urlInterceptArray[i]]) {
            return NO;
        }
    }
    return YES;
}

- (void)new_webViewDidFinishLoad:(UIWebView *)webView {
    [self updateJSContextNotify];
    BOOL finishLoadEvent = [[self valueForKey:@"finishLoadEvent"] boolValue];
    if (finishLoadEvent) {
        
        NSDictionary *data = [self baseInfo];
        [self fireEvent:@"pagefinish" params:data domChanges:@{@"attrs": @{@"src":webView.request.URL.absoluteString}}];
    }
}

- (NSMutableDictionary<NSString *, id> *)baseInfo {
    UIWebView *webView = (UIWebView *)self.view;
    NSMutableDictionary<NSString *, id> *info = [NSMutableDictionary new];
    [info setObject:webView.request.URL.absoluteString ?: @"" forKey:@"url"];
    [info setObject:[webView stringByEvaluatingJavaScriptFromString:@"document.title"] ?: @"" forKey:@"title"];
    [info setObject:@(webView.canGoBack) forKey:@"canGoBack"];
    [info setObject:@(webView.canGoForward) forKey:@"canGoForward"];
    return info;
}

- (void)updateJSContextNotify {
    UIWebView *_webview = (UIWebView *)self.view;
    
    JSContext *_jsContext = [_webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    __weak typeof(self) weakSelf = self;
    
    // This method will be abandoned slowly.
    _jsContext[@"$notifyWeex"] = ^(JSValue *data) {
        if (weakSelf.notifyEvent) {
            [weakSelf fireEvent:@"notify" params:[data toDictionary]];
        }
    };
}

@end
