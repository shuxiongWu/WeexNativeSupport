//
//  HNDatePickerView.m
//  BaseProject
//
//  Created by HN on 16/10/10.
//  Copyright © 2016年 HN. All rights reserved.
//

#import "HNDatePickerView.h"
#import "MacrosAndConstants.h"
#import "PublicFunction.h"
@interface HNDatePickerView()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSString                 *_pikeAddress;
}
@property (nonatomic,strong)NSMutableArray *datasource;
@property (nonatomic,strong)NSMutableArray *cityArray;
@property (nonatomic,strong)NSMutableArray *district;


@end

@implementation HNDatePickerView

-(id)initDatePickerViewDelegate:(id)delegate{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self)
    {
        self.delegate = delegate;
        [self createDatePickerView];
    }
    return self;
}
-(void)createDatePickerView{
    
    
    self.backgroundColor = SetColor(@"#000000", 0.3);
    self.bgView  = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenH, ScreenW, 220)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenW, 50)];
    titleLabel.text = @"请选择日期";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:titleLabel];
    
    for (int i=0; i<2; i++)
    {
        UIButton *cancelBtn = [PublicFunction getButtonInControl:self frame:CGRectMake(10, 10, 80, 30) title:nil align:@"center" color:SetColor(@"#333333", 1) fontsize:16 tag:i+1 clickAction:@selector(btnClick:)];
        //[cancelBtn setImage:[UIImage imageNamed:@"time_cancel"] forState:UIControlStateNormal];
        cancelBtn.layer.frame = CGRectMake(cancelBtn.frame.origin.x, cancelBtn.frame.origin.y, 60, 30);
        [self.bgView addSubview:cancelBtn];
        if (i==1)
        {
            //[cancelBtn setImage:[UIImage imageNamed:@"time_save"] forState:UIControlStateNormal];
            [cancelBtn setTitle:@"确定" forState:UIControlStateNormal];
            [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
            cancelBtn.layer.borderWidth = 1.f;
            cancelBtn.layer.borderColor = [UIColor grayColor].CGColor;
            cancelBtn.layer.cornerRadius = 2.f;
            cancelBtn.layer.masksToBounds = YES;
            cancelBtn.frame = CGRectMake(ScreenW- 100, cancelBtn.frame.origin.y, cancelBtn.bounds.size.width, cancelBtn.bounds.size.height);
            cancelBtn.layer.frame = CGRectMake(cancelBtn.frame.origin.x+30, cancelBtn.frame.origin.y, 60, 30);
        }else{
            UIButton *cancelBtn1 = [PublicFunction getButtonInControl:self frame:CGRectMake(10, 5, 80, 30) title:nil align:@"center" color:SetColor(@"#333333", 1) fontsize:16 tag:i+1 clickAction:@selector(btnClick:)];
            //[cancelBtn setImage:[UIImage imageNamed:@"time_cancel"] forState:UIControlStateNormal];
            cancelBtn1.layer.frame = CGRectMake(cancelBtn1.frame.origin.x, cancelBtn1.frame.origin.y, 60, 30);
            [self.bgView addSubview:cancelBtn1];
            [cancelBtn1 setTitle:@"取消" forState:UIControlStateNormal];
            [cancelBtn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            cancelBtn1.titleLabel.font = [UIFont systemFontOfSize:15.f];
            cancelBtn1.layer.borderWidth = 1.f;
            cancelBtn1.layer.borderColor = [UIColor grayColor].CGColor;
            cancelBtn1.layer.cornerRadius = 2.f;
            cancelBtn1.layer.masksToBounds = YES;
            cancelBtn1.frame = CGRectMake(ScreenW- 100, cancelBtn.frame.origin.y, cancelBtn.bounds.size.width, cancelBtn.bounds.size.height);
            cancelBtn1.layer.frame = CGRectMake(15, cancelBtn.frame.origin.y, 60, 30);
        }
    }
   
//    UIButton *sureBtn = [PublicFunction getButtonInControl:self frame:CGRectMake(MainS_Width- 100, cancelBtn.frame.origin.y, cancelBtn.bounds.size.width, cancelBtn.bounds.size.height) title:@"确定" align:@"center" color:SetColor(@"#333333", 1) fontsize:16 tag:2 clickAction:@selector(btnClick:)];
//    sureBtn.layer.frame = CGRectMake(sureBtn.frame.origin.x+30, sureBtn.frame.origin.y, 60, 40);
//    sureBtn.layer.borderColor =SetColor(@"#999999", 1).CGColor;
//    sureBtn.layer.borderWidth = 1;
//    sureBtn.layer.cornerRadius=6;
//    sureBtn.layer.masksToBounds=YES;
//    [self.bgView addSubview:sureBtn];
    
    CALayer *line  =[[CALayer alloc]init];
    line.frame = CGRectMake(0,55, ScreenW, 1);
    line.backgroundColor = SetColor(@"#EEEEEE", 1).CGColor;
    [_bgView.layer addSublayer:line];
    
    
    
    self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0,60 , ScreenW, self.bgView.bounds.size.height-60)];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.bgView addSubview:self.datePicker];
}
-(void)btnClick:(UIButton *)btn{
    
    if ([_delegate respondsToSelector:@selector(datePickerViewButtonIndex:withDatePicker:)])
    {
             [_delegate datePickerViewButtonIndex:btn.tag withDatePicker:self.datePicker];
    }
    [self dismissDatePicker];
    
}
-(void)showDatePickerView{
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:self];
    [UIView animateWithDuration:0.35 animations:^{
        
        _bgView.frame = CGRectMake((ScreenW -_bgView.bounds.size.width)/2.0, [UIScreen mainScreen].bounds.size.height-_bgView.bounds.size.height, _bgView.bounds.size.width, _bgView.bounds.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 消失

-(void)dismissDatePicker{
    [UIView animateWithDuration:0.35 animations:^{
        
        _bgView.frame = CGRectMake(0, ScreenH, _bgView.bounds.size.width, _bgView.bounds.size.height);
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


 //选地址的
#pragma mark - 选地址的
-(id)initLocationPickerViewDelegate:(id)delegate withProv:(NSString *)prov withCity:(NSString *)city withArea:(NSString *)area{
    
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self)
    {
        self.delegate = delegate;
        [self createLocationPickerViewWithProv:prov withCity:city withArea:area];
    }
    return self;
}

-(void)createLocationPickerViewWithProv:(NSString *)prov withCity:(NSString *)city withArea:(NSString *)area{
    
    NSString *path =[[NSBundle mainBundle] pathForResource:@"address" ofType:@"plist"];
//    NSDictionary *dictionary=[[NSDictionary alloc]initWithContentsOfFile:path];
    _datasource = [NSMutableArray arrayWithContentsOfFile:path];//[NSMutableArray arrayWithArray:[dictionary objectForKey:@"address"]];
    _cityArray =[NSMutableArray arrayWithArray:[[_datasource objectAtIndex:0]objectForKey:@"sub"]];
    _district =[NSMutableArray arrayWithArray:[[_cityArray objectAtIndex:0]objectForKey:@"sub"]];
    NSString *seletedProvince = [[_datasource objectAtIndex:0]objectForKey:@"name"];
    _pikeAddress =[NSString stringWithFormat:@"%@ %@ %@",seletedProvince,[[_cityArray objectAtIndex:0]objectForKey:@"name"],[[_district objectAtIndex:0] objectForKey:@"name"]];
    self.backgroundColor = SetColor(@"#000000", 0.3);
    self.bgView  = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenH, ScreenW, 220)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    for (int i=0; i<2; i++)
    {
        UIButton *cancelBtn = [PublicFunction getButtonInControl:self frame:CGRectMake(10, 5, 80, 50) title:@"取消" align:@"center" color:SetColor(@"#333333", 1) fontsize:16 tag:i+1 clickAction:@selector(cancelBtnAndSureBtnClick:)];
        cancelBtn.layer.frame = CGRectMake(cancelBtn.frame.origin.x, cancelBtn.frame.origin.y, 60, 40);
        cancelBtn.layer.borderColor =SetColor(@"#999999", 1).CGColor;
        cancelBtn.layer.borderWidth = 1;
        cancelBtn.layer.cornerRadius=6;
        [cancelBtn setTitleColor:FontColor forState:UIControlStateNormal];
        cancelBtn.layer.masksToBounds=YES;
        [self.bgView addSubview:cancelBtn];
        if (i==1)
        {
            [cancelBtn setTitle:@"确定" forState:UIControlStateNormal];
            [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            cancelBtn.frame = CGRectMake(ScreenW- 100, cancelBtn.frame.origin.y, cancelBtn.bounds.size.width, cancelBtn.bounds.size.height);
            cancelBtn.layer.frame = CGRectMake(cancelBtn.frame.origin.x+30, cancelBtn.frame.origin.y, 60, 40);
        }
    }

    CALayer *line  =[[CALayer alloc]init];
    line.frame = CGRectMake(0, 60, ScreenW, 1);
    line.backgroundColor = SetColor(@"#EEEEEE", 1).CGColor;
    [_bgView.layer addSublayer:line];
    
    self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 65, ScreenW, _bgView.bounds.size.height-65)];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [_bgView addSubview:self.pickerView];
    
    if (prov&&city&&area)
    {
        NSInteger selectOneRow = 0;
        for (int i=0;i<_datasource.count;i++)
        {
            NSDictionary *dic = _datasource[i];
            //DLog(@"======%@===%@",dic[@"name"],[dic class]);
            if ([dic[@"name"] isEqualToString:prov])
            {
                selectOneRow = i;
                break;
            }
        }
        _cityArray = [NSMutableArray arrayWithArray:[[_datasource objectAtIndex:selectOneRow]objectForKey:@"sub"]];
        NSInteger selectTowRow = 0;
        for (int i=0;i<_cityArray.count;i++) {
            NSDictionary *dic = _cityArray[i];
            //DLog(@"===city===%@===%@",dic[@"name"],[dic class]);
            if ([dic[@"name"] isEqualToString:city])
            {
                selectTowRow = i;
                break;
            }
        }
        _district = [NSMutableArray arrayWithArray:[[_cityArray objectAtIndex:selectTowRow]objectForKey:@"sub"]];
        NSInteger selectThreeRow = 0;
        for (int i=0;i<_district.count;i++)  {
            
            NSString *nameStr = [_district[i] objectForKey:@"name"];
//            DLog(@"===area===%@==",nameStr);

            if ([nameStr isEqualToString:area]) {
                selectThreeRow = i;
                break;
            }
        }
        [_pickerView reloadAllComponents];
        
        [_pickerView selectRow:selectOneRow inComponent:0 animated:YES];
        [_pickerView selectRow:selectTowRow inComponent:1 animated:YES];
        [_pickerView selectRow:selectThreeRow inComponent:2 animated:YES];
        NSString *seletedProvince = [[_datasource objectAtIndex:selectOneRow]objectForKey:@"name"];
        _pikeAddress =[NSString stringWithFormat:@"%@ %@ %@",seletedProvince,[[_cityArray objectAtIndex:selectTowRow]objectForKey:@"name"],_district.count>selectThreeRow?[[_district objectAtIndex:selectThreeRow] objectForKey:@"name"]:@""];
    }  
}
-(void)cancelBtnAndSureBtnClick:(UIButton *)btn{
    
    if ([_delegate respondsToSelector:@selector(pickerViewButtonIndex:withPickerView:withString:)])
    {
       [_delegate pickerViewButtonIndex:btn.tag withPickerView:self.pickerView withString:_pikeAddress];
    }
    [self dismissDatePicker];
}
#pragma mark - pickerViewDelegate
- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        
        pickerLabel =[[UILabel alloc]init];
//        pickerLabel.backgroundColor = [UIColor redColor];
        pickerLabel.minimumScaleFactor = 8;
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.numberOfLines =0;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:13]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
//    if (0 ==component) {
//        
//        return  [[_datasource objectAtIndex:row]objectForKey:@"name"];
//    }else if (1==component){
//        
//        return  [[_cityArray objectAtIndex:row]objectForKey:@"name"];
//        
//    }else{
//        return  [_district objectAtIndex:row];
//    }
    
    CGFloat componentWidth = ([UIScreen mainScreen].bounds.size.width-20)/3;
    return componentWidth;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return ScaleHeight(45);
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 3;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (0==component) {
        return  _datasource.count;
    }else if (1 ==component){
        return _cityArray.count;
        
    }else{
        return _district.count;
    }
}
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (0 ==component) {
        
        return  [[_datasource objectAtIndex:row]objectForKey:@"name"];
    }else if (1==component){
        
        return  [[_cityArray objectAtIndex:row]objectForKey:@"name"];
        
    }else{
        return  [[_district objectAtIndex:row] objectForKey:@"name"];
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component ==0) {
        NSString *seletedProvince = [[_datasource objectAtIndex:row]objectForKey:@"name"];
        _cityArray =[NSMutableArray arrayWithArray:[[_datasource objectAtIndex:row]objectForKey:@"sub"]];
        _district =[NSMutableArray arrayWithArray:[[_cityArray objectAtIndex:0]objectForKey:@"sub"]];
        _pikeAddress =[NSString stringWithFormat:@"%@ %@ %@",seletedProvince,[[_cityArray objectAtIndex:0]objectForKey:@"name"],_district.count>0?[[_district objectAtIndex:0] objectForKey:@"name"]:@""];
        
//        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:2 inSection:0];
        
        
        [self.pickerView reloadAllComponents];
        [self.pickerView selectRow:0 inComponent:1 animated:YES];
        [self.pickerView selectRow:0 inComponent:2 animated:YES];
        
    }else if (1==component){
        NSString *seletedcity = [[_cityArray objectAtIndex:row]objectForKey:@"name"];
        _district =[NSMutableArray arrayWithArray:[[_cityArray objectAtIndex:row]objectForKey:@"sub"]];
        [self changeAddressString:seletedcity withcomponent:1];
        NSString *seletedDist = _district.count>0?[[_district objectAtIndex:0] objectForKey:@"name"]:@"";
        [self changeAddressString:seletedDist withcomponent:2];
        [self.pickerView reloadComponent:2];
        [self.pickerView selectRow:0 inComponent:2 animated:YES];
        
    }else{
        NSString  *seletedDist =_district.count>row?[[_district objectAtIndex:row] objectForKey:@"name"]:@"";
        [self changeAddressString:seletedDist withcomponent:2];
    }
    
}
-  (void)changeAddressString:(NSString *)string withcomponent:(NSInteger)number
{
    NSMutableArray *array = (NSMutableArray*)[_pikeAddress componentsSeparatedByString:@" "];
    if (0 ==number) {
        [array insertObject:string atIndex:0];
    }else if (1==number){
        [array insertObject:string atIndex:1];
    }else{
        [array insertObject:string atIndex:2];
    }
    _pikeAddress =[NSString stringWithFormat:@"%@ %@ %@",[array objectAtIndex:0],[array objectAtIndex:1],[array objectAtIndex:2]];
//    DLog(@"_pikeAddress=%@----",_pikeAddress);
    
    
}
@end
