//
//  CCZSpreadButton.h
//  CCZSpreadButton
//
//  Created by 金峰 on 2016/11/10.
//  Copyright © 2016年 金峰. All rights reserved.
//

#import "WeexSpreadComponentry.h"

@protocol WeexSpreadButtonDelegate;
@interface WeexSpreadButton : WeexSpreadComponentry
@property (nonatomic, weak) id <WeexSpreadButtonDelegate> delegate;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *selImage;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) NSUInteger itemsNum;

+ (instancetype)spreadButtonWithCapacity:(NSUInteger)itemsNum;
- (void)spreadButtonDidClickItemAtIndex:(void(^)(NSUInteger index))indexBlock;
@end

@protocol WeexSpreadButtonDelegate <NSObject>
@optional
- (void)spreadButton:(WeexSpreadButton *)spreadButton didSelectedAtIndex:(NSUInteger)index withSelButton:(UIButton *)button;
@end
