//
//  WeakScriptMessageDelegate.h
//  WeexNativeSupport
//
//  Created by YANJUNCHEN on 2020/9/18.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>


@interface WeakScriptMessageDelegate : NSObject <WKScriptMessageHandler>

@property (nonatomic,weak)id<WKScriptMessageHandler> scriptDelegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end

