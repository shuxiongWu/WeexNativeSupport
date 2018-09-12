//
//  CMJFInputHeader.m
//  CMfspay
//
//  Created by 超盟 on 2017/12/7.
//  Copyright © 2017年 超盟. All rights reserved.
//

#import "CMJFInputHeader.h"
#import "MacrosAndConstants.h"
@implementation CMJFInputHeader

//- (instancetype)initWithFrame:(CGRect)frame{
//    if (self = [super initWithFrame:frame]) {
//
//    }
//    return self;
//}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorFromRGB(0xf5f5f5);
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    UIColor *color = UIColorFromRGB(0x3BC329);
    [color set];  //设置线条颜色
    UIBezierPath* aPath = [UIBezierPath bezierPath];
    aPath.lineWidth = 10.0;//设置线条的粗细
    aPath.lineCapStyle = kCGLineCapRound;  //线条拐角
    aPath.lineJoinStyle = kCGLineCapRound;  //终点处理
    // 设置多边形最开始的点
    [aPath moveToPoint:CGPointMake(0.0, 0.0)];
    // 画相应的线条
    [aPath addLineToPoint:CGPointMake(kScreenWidth, 0.0)];
    [aPath addLineToPoint:CGPointMake(kScreenWidth, 70)];
    [aPath addLineToPoint:CGPointMake(0.0, 200.0)];
    [aPath closePath]; //第五条线通过调用closePath方法得到的
    [aPath fill];//图形内部填充
}
@end
