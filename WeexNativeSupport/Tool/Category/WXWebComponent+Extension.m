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

+ (void)load {
    [self weex_swizzle:[self class] Method:@selector(initWithRef:type:styles:attributes:events:weexInstance:) withMethod:@selector(new_initWithRef:type:styles:attributes:events:weexInstance:)];
        [self weex_swizzle:[self class] Method:@selector(viewDidLoad) withMethod:@selector(new_viewDidLoad)];
}

-(instancetype)new_initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance {
    id ret = [self new_initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    
    self.notifyEvent = [attributes[@"notifyEvent"] boolValue];
    self.isBounces = [attributes[@"isBounces"] boolValue];
    return ret;
}

- (void)new_viewDidLoad {
    [self new_viewDidLoad];
    
    [(UIScrollView *)[[self.view subviews] objectAtIndex:0] setBounces:self.isBounces];
}

@end
