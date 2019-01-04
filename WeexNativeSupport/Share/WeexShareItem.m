//
//  MJShareItem.m
//  MJNativeShare
//
//  Created by robert on 16/7/25.
//  Copyright © 2016年 robert. All rights reserved.
//


#import "WeexShareItem.h"

@interface WeexShareItem ()<UIActivityItemSource>
//传入的图片
@property (nonatomic, strong) UIImage *img;
//保存图片的本地路径
@property (nonatomic, strong) NSURL *filePath;
@end

@implementation WeexShareItem

-(instancetype)initWithImage:(UIImage *)img andfile:(NSURL *)fileURl
{
    self = [super init];
    if (self) {
        _img = img;
        _filePath = fileURl;
    }
    return self;
}


#pragma mark - UIActivityItemSource代理
//@required
-(id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return _img;
}
//@required
-(id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    return _filePath;
}

//@optional
-(NSString*)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    
    return nil;
}

//@optional
-(UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(NSString *)activityType suggestedSize:(CGSize)size{
    return nil;
}

//@optional
-(NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType
{
    return nil;
}
@end
