//
//  PublicFunction.h
//  houseManage
//
//  Created by zhu xian on 12-3-3.
//  Copyright 2012 z. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>
#import <UIKit/UIKit.h>

@interface WeexPublicFunction : NSObject
{
    
}
@property (nonatomic, strong) NSMutableArray *urlArray;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *rangeArr;
@property (nonatomic, copy) NSMutableString *tempString;

+(UIImageView *)getImageView:(CGRect)frame imageName:(NSString *)imageName;
+(UISearchBar *)getSearchBarInControl:(id)control frame:(CGRect)frame placeholder:(NSString *)placeholder tag:(int)tag;



+(UITextView *)getTextView:(CGRect)frame   text:(NSString *)text size:(int)size;
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text textSize:(int)size  textColor:(UIColor *)textColor textBgColor:(UIColor *)bgcolor  textAlign:(NSString *)align;
+(UISwitch *)getSwitchInControl:(id)control frame:(CGRect)frame clickAction:(SEL)clickAction;
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text font:(UIFont *)font color:(UIColor *)color;
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text font:(UIFont *)font;
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text;
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text  size:(int)size align:(NSString *)align;
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text size:(int)size;
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text imageName:(NSString *)imageName;
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text fontSize:(int)fontSize color:(UIColor *)color align:(NSString *)align;
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text align:(NSString *)align;
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text fontSize:(int)fontSize color:(UIColor *)color;
+(UITextField *)getTextFieldInControl:(id)control frame:(CGRect)frame  tag:(NSInteger)tag  returnType:(NSString *)returnType text:(NSString *)text placeholder:(NSString *)placeholder;

+(UIButton *)getButtonInControl:(id)control frame:(CGRect)frame imageName:(NSString *)imageName title:(NSString *)title  tag:(int)tag clickAction:(SEL)clickAction;
+(UIButton *)getButtonInControl:(id)control frame:(CGRect)frame TitleImageName:(NSString *)imageName title:(NSString *)title tag:(int)tag clickAction:(SEL)clickAction;
+ (UIImage *) getImage:(UIImage *)image width:(int)width height:(int)height;

+(UITextField *)addTextField:(CGRect)frame  tag:(NSInteger)tag returnType:(NSString *)returnType;
+(UIButton *)getButtonInControl:(id)control frame:(CGRect)frame imageName:(NSString *)imageName title:(NSString *)title clickAction:(SEL)clickAction;

+(UIButton *)getButtonInControl:(id)control frame:(CGRect)frame  title:(NSString *)title align:(NSString *)align  color:(UIColor *)color fontsize:(int)fontsize tag:(int)tag clickAction:(SEL)clickAction;
+(UITextView *)getTextViewInControl:(id)control frame:(CGRect)frame  tag:(NSInteger)tag returnType:(NSString *)returnType;
+(UITextField *)getTextFieldInControl:(id)control frame:(CGRect)frame  tag:(NSInteger)tag returnType:(NSString *)returnType;

+(UIImage *)getImage:(NSString *)imageName;
+(UIButton *)getButtonInControl:(id)control frame:(CGRect)frame  title:(NSString *)title align:(NSString *)align  color:(UIColor *)color fontsize:(int)fontsize tag:(int)tag clickAction:(SEL)clickAction imageName:(NSString *)imageName;
+ (UIImage *) getThumbnailImage:(UIImage *)image width:(int)width height:(int)height;
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text BGColor:(UIColor *)BGColor textColor:(UIColor *)textColor size:(NSInteger)size;
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text color:(UIColor *)color size:(NSInteger)size;




/**
 *@brief 输入文字判断文字中是否有链接返回文字（用于解决帖子或活动详情出现链接计算文字高度问题）
 */
-(NSString *)BrianPublicStringWithUrlString:(NSString *)content;
@end
