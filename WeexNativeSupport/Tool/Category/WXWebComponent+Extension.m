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


@end
