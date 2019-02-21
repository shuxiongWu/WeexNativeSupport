//
//  ASCameraAVPlayer.h
//  PlayCarParadise
//
//  Created by wushuxiong on 2018/5/24.
//  Copyright © 2018年 CarFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASCameraAVPlayer : UIView

- (instancetype)initWithFrame:(CGRect)frame withShowInView:(UIView *)bgView url:(NSURL *)url;

@property (copy, nonatomic) NSURL *videoUrl;

- (void)stopPlayer;

@end
