//
//  CMSuspensionComponent.m
//  WeexDemo
//
//  Created by 吴述雄 on 2018/11/22.
//  Copyright © 2018 wusx. All rights reserved.
//

#import "CMSuspensionComponent.h"
#import "CCZSpreadButton.h"
#import <WeexSDK/WeexSDK.h>
@interface CMSuspensionComponent ()

@property (nonatomic, strong) CCZSpreadButton *btn;
    
@end

@implementation CMSuspensionComponent

+(void)load {
    [WXSDKEngine registerComponent:@"suspensionButton" withClass:NSClassFromString(@"CMSuspensionComponent")];
}

- (UIView *)loadView {
    _btn = [[CCZSpreadButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    _btn.normalImage = [UIImage imageNamed:@"plus_L"];
    _btn.selImage = [UIImage imageNamed:@"plus_F"];
    _btn.images = @[@"lock_F",@"lock_F",@"lock_F",@"lock_F",@"lock_F",@"lock_F",@"lock_F"];
    [_btn spreadButtonDidClickItemAtIndex:^(NSUInteger index) {
        NSLog(@"%ld",index);
    }];
    return _btn;
}

-(void)viewDidLoad {
    
}

-(instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance{
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        
    }
    return self;
}

@end
