//
//  CMSuspensionComponent.m
//  WeexDemo
//
//  Created by 吴述雄 on 2018/11/22.
//  Copyright © 2018 wusx. All rights reserved.
//

#import "WeexSuspensionComponent.h"
#import "WeexSpreadButton.h"
#import <WeexSDK/WeexSDK.h>
@interface WeexSuspensionComponent ()

@property (nonatomic, strong) WeexSpreadButton *btn;
@property (nonatomic, strong) NSDictionary *attribute;
@property (nonatomic, assign) BOOL isAllowSelectIndex;
@end

@implementation WeexSuspensionComponent

+(void)load {
    [WXSDKEngine registerComponent:@"suspensionButton" withClass:NSClassFromString(@"WeexSuspensionComponent")];
}

- (UIView *)loadView {
    NSLog(@"加载View");
    _btn = [[WeexSpreadButton alloc] init];

    return _btn;
}

-(void)viewDidLoad {
    NSLog(@"View加载完成");
    _btn.normalImage = [UIImage imageNamed:@"plus_L"];
    _btn.selImage = [UIImage imageNamed:@"plus_F"];
    _btn.itemsNum = 5;
    _btn.images = @[@"lock_F",@"lock_F",@"lock_F",@"lock_F",@"lock_F",@"lock_F",@"lock_F"];
    [self setAttr];
    [_btn spreadButtonDidClickItemAtIndex:^(NSUInteger index) {
        if (_isAllowSelectIndex) {
            [self fireEvent:@"isAllowSelectIndex" params:@{
                                                           @"index":@(index)
                                                           }];
        }
    }];
}

- (void)setAttr{
    //是否开启粘滞
    if (_attribute[@"openViscousity"]) {
        _btn.spreadButtonOpenViscousity = [_attribute[@"openViscousity"] boolValue];
    }
    //弹出的距离
    if (_attribute[@"spreadDistance"]) {
        _btn.spreadDis = [_attribute[@"spreadDistance"] floatValue];
    }
    //是否是展开状态
    if (_attribute[@"isSpreading"]) {
        _btn.isSpreading = [_attribute[@"isSpreading"] boolValue];
    }
    //弹出按钮半径
    if (_attribute[@"radius"]) {
        _btn.radius = [_attribute[@"radius"] floatValue];
    }
//    //主按钮位置以及大小
//    if (_attribute[@"frame"]) {
//        NSLog(@"%@",_attribute[@"frame"]);
//        _btn.frame = [_attribute[@"frame"] CGRectValue];
//        NSLog(@"%@",NSStringFromCGRect(_btn.frame));
//
//    }
    //主按钮normal图片
    if (_attribute[@"normalImage"]) {
        _btn.normalImage = [UIImage imageNamed:_attribute[@"normalImage"]];
    }
    //主按钮select图片
    if (_attribute[@"selectImage"]) {
        _btn.selImage = [UIImage imageNamed:_attribute[@"selectImage"]];
    }
    //子按钮图片数组
    if (_attribute[@"subImages"]) {
        _btn.itemsNum = [_attribute[@"subImages"] count];
        _btn.images = _attribute[@"subImages"];
    }
}

-(instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance{
    NSLog(@"设置属性");
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        self.attribute = attributes;
        
    }
    return self;
}

-(void)updateAttributes:(NSDictionary *)attributes {
    
}

-(void)addEvent:(NSString *)eventName{
    if ([eventName isEqualToString:@"isAllowSelectIndex"]) {
        _isAllowSelectIndex = YES;
    }
}

@end
