//
//  WeakScriptMessageDelegate.m
//  WeexNativeSupport
//
//  Created by YANJUNCHEN on 2020/9/18.
//

#import "WeakScriptMessageDelegate.h"

@implementation WeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}


@end
