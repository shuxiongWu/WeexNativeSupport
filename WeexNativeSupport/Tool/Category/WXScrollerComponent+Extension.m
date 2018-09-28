//
//  WXScrollerComponent+Extension.m
//
//  Created by HJaycee on 2017/8/14.
//

#import "WXScrollerComponent+Extension.h"
#import <objc/runtime.h>
#import <MJRefresh.h>

/*
 前端在dom中加上事件，原生判断有refresh和loading事件，绑定下拉刷新控件，使用fireEvent调用前端的函数
 前端更改属性来关闭下拉刷新动画
 */

@interface WXScrollerComponent ()

@property (nonatomic) BOOL headerExist;
@property (nonatomic) BOOL footerExist;

@end

@implementation WXScrollerComponent (Extension)

- (void)setHeaderExist:(BOOL)headerExist {
    objc_setAssociatedObject(self, @selector(headerExist), @(headerExist), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)headerExist {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFooterExist:(BOOL)footerExist {
    objc_setAssociatedObject(self, @selector(footerExist), @(footerExist), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)footerExist {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

+ (void)load {
    [self weex_swizzle:[self class] Method:@selector(initWithRef:type:styles:attributes:events:weexInstance:) withMethod:@selector(new_initWithRef:type:styles:attributes:events:weexInstance:)];
    [self weex_swizzle:[self class] Method:@selector(updateAttributes:) withMethod:@selector(new_updateAttributes:)];
    [self weex_swizzle:[self class] Method:@selector(viewDidLoad) withMethod:@selector(new_viewDidLoad)];
}

-(instancetype)new_initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance {
    id ret = [self new_initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    for (NSString *e in events) {
        if ([e isEqualToString:@"refresh"]) {
            self.headerExist = YES;
        }
        if ([e isEqualToString:@"loading"]) {
            self.footerExist = YES;
        }
    }
    return ret;
}

- (void)new_updateAttributes:(NSDictionary *)attributes {
    [self new_updateAttributes:attributes];
    
    if (attributes[@"refreshDisplay"]) {
        if ([attributes[@"refreshDisplay"] isEqualToString:@"hide"]) {
            UIScrollView *scrollView = (UIScrollView *)self.view;
            [scrollView.mj_header endRefreshing];
            [UIView animateWithDuration:0.4 animations:^{
                [(UIScrollView *)self.view setContentOffset:CGPointZero];
            }];
        }
    }
    if (attributes[@"loadingDisplay"]) {
        if ([attributes[@"loadingDisplay"] isEqualToString:@"hide"]) {
            UIScrollView *scrollView = (UIScrollView *)self.view;
            [scrollView.mj_footer endRefreshing];
        }
    }
    if (attributes[@"noMoreData"]) {
        if ([attributes[@"noMoreData"] isEqualToString:@"show"]) {
            UIScrollView *scrollView = (UIScrollView *)self.view;
            [scrollView.mj_footer endRefreshingWithNoMoreData];
        }else{
            UIScrollView *scrollView = (UIScrollView *)self.view;
            [scrollView.mj_footer endRefreshing];
        }
    }
}

- (void)new_viewDidLoad {
    [self new_viewDidLoad];
    
    if (self.headerExist) {
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
        [(UIScrollView *)self.view setMj_header:header];
    }
    
    if (self.footerExist) {
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loading)];
        [(UIScrollView *)self.view setMj_footer:footer];
    }
}

- (void)refresh {
    [self fireEvent:@"refresh" params:nil];
}

- (void)loading {
    [self fireEvent:@"loading" params:nil];
}

@end
