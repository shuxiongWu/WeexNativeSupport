//
//  CMWXCarouselComponent.m
//  WeexDemo
//
//  Created by 吴述雄 on 2019/3/11.
//  Copyright © 2019 wusx. All rights reserved.
//

#import "CMWXCarouselComponent.h"
#import <WeexSDK/WeexSDK.h>
#import "iCarousel.h"
#if __has_include(<SDWebImage/SDWebImageManager.h>)
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>
#elif __has_include("SDWebImageManager.h")
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#endif

@interface CMWXCarouselComponent ()<iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, strong) NSArray *urlArray; //网络图片
@property (nonatomic, assign) iCarouselType carouseType;  //展现类型
@property (nonatomic, assign) NSInteger currentIndex;     //当前展示第几个
@property (nonatomic, copy) NSString *placeholder;  //占位图

@end

@implementation CMWXCarouselComponent

+(void)load {
    [WXSDKEngine registerComponent:@"carouse" withClass:NSClassFromString(@"CMWXCarouselComponent")];
}

- (UIView *)loadView {
    _carousel = [[iCarousel alloc] init];
    return _carousel;
}

- (void)viewDidLoad {
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    [self setAttributes];
}

- (void)setAttributes {
    self.carousel.type = self.carouseType;
    self.currentIndex = self.currentIndex;
}

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance {
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        if (attributes[@"urlArray"]) {
            _urlArray = attributes[@"urlArray"];
        }
        if (attributes[@"carouseType"]) {
            _carouseType = [attributes[@"carouseType"] integerValue];
        }
        if (attributes[@"currentIndex"]) {
            _currentIndex = [attributes[@"currentIndex"] integerValue];
        }
        if (attributes[@"placeholder"]) {
            _placeholder = attributes[@"placeholder"];
        }
    }
    return self;
}

-(void)updateAttributes:(NSDictionary *)attributes {
    if (attributes[@"urlArray"]) {
        _urlArray = attributes[@"urlArray"];
        [_carousel reloadData];
    }
    if (attributes[@"currentIndex"]) {
        _currentIndex = [attributes[@"currentIndex"] integerValue];
        [_carousel reloadData];
    }
    
}

#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [_urlArray count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.height)];
        view.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    UIImageView *imageView = (UIImageView *)view;
#if __has_include(<SDWebImage/SDWebImageManager.h>) || __has_include("SDWebImageManager.h")
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.urlArray[index]] placeholderImage:[UIImage imageNamed:self.placeholder]];
#else
    NSAssert(NO, @"请导入SDWebImage后再使用网络图片功能");
#endif
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.1;
    }
    return value;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    NSLog(@"%@",_urlArray[carousel.currentItemIndex]);
    [self fireEvent:@"currentUrl" params:@{
                                             @"imgUrl":_urlArray[carousel.currentItemIndex]
                                             }];
}

@end
