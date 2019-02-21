//
//  ASCameraViewController.h
//  PlayCarParadise
//
//  Created by lw on 2018/5/24.
//  Copyright © 2018年 CarFun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TakeOperationSureBlock)(id item);

@interface ASCameraViewController : UIViewController

@property (copy, nonatomic) TakeOperationSureBlock takeBlock;

@property (assign, nonatomic) NSInteger ASSeconds;

@end
