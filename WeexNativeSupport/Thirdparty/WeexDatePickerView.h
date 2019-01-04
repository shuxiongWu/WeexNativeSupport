//
//  HNDatePickerView.h
//  BaseProject
//
//  Created by HN on 16/10/10.
//  Copyright © 2016年 HN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WeexdatePickerDelegate;

@interface WeexDatePickerView : UIView

@property (nonatomic,strong)UIDatePicker *datePicker;
@property (nonatomic,strong)UIPickerView *pickerView;

@property (nonatomic,strong)UIView *bgView;

@property (nonatomic,assign)id<WeexdatePickerDelegate> delegate;

-(id)initDatePickerViewDelegate:(id)delegate;
-(void)showDatePickerView;

-(id)initLocationPickerViewDelegate:(id)delegate withProv:(NSString *)prov withCity:(NSString *)city withArea:(NSString *)area;

@end

@protocol WeexdatePickerDelegate <NSObject>
@optional
-(void)datePickerViewButtonIndex:(NSInteger)index withDatePicker:(UIDatePicker *)datePicker;
-(void)pickerViewButtonIndex:(NSInteger)index withPickerView:(UIPickerView *)pikerView withString:(NSString *)locationStr;
@end
