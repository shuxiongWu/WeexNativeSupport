//
//  PublicFunction.m
//  houseManage
//
//  Created by zhu xian on 12-3-3.
//  Copyright 2012 z. All rights reserved.
//

#import "PublicFunction.h"

#import "MacrosAndConstants.h"

#include <sys/xattr.h> 
#import <sys/sysctl.h>
#include<unistd.h>
#include<netdb.h>
#define navigationColor [UIColor blackColor]

@implementation PublicFunction
+(UIImageView *)getImageView:(CGRect)frame imageName:(NSString *)imageName
{
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:frame];
    imageView.image=[UIImage imageNamed:imageName];
    
    return imageView;
}

+(UIImage *)getImage:(NSString *)imageName
{
	if ([imageName rangeOfString:@"."].location != NSNotFound)
    {
		NSArray *names = [imageName componentsSeparatedByString: @"."];
		return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[names objectAtIndex:0] ofType:[names objectAtIndex:1]]];
	}
	else
    {
		return nil;
	}
}


//缩略图
+ (UIImage *) getImage:(UIImage *)image width:(int)width height:(int)height
{
	NSLog(@"scaleFromImage.....");
	CGSize size = CGSizeMake(width,height);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return newImage;
}

+(UITextField *)addTextField:(CGRect)frame  tag:(NSInteger)tag returnType:(NSString *)returnType
{
    UITextField  *TextField = [[UITextField alloc] initWithFrame:frame];
	//TextField.delegate = self;
	TextField.tag=tag;
	TextField.textAlignment = NSTextAlignmentLeft;
	TextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	TextField.returnKeyType = UIReturnKeyNext;
	TextField.font=[UIFont fontWithName:@"Arial" size:16];
	TextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	TextField.layer.cornerRadius=2.0f;
    TextField.layer.masksToBounds=YES;
    TextField.layer.borderColor=[[UIColor grayColor] CGColor];
    TextField.layer.borderWidth= 1.0f;
    TextField.textColor =[UIColor blackColor];
    if ([returnType isEqualToString:@"next"]) {
        TextField.returnKeyType = UIReturnKeyNext;
    }
    else {
        TextField.returnKeyType = UIReturnKeyDone;
    }
    UIView *leftView=[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 5.0f,30.0f)];
    TextField.leftView=leftView;
	TextField.leftViewMode = UITextFieldViewModeAlways;
	
    
    return TextField;
    
}
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text BGColor:(UIColor *)BGColor textColor:(UIColor *)textColor size:(NSInteger)size
{
	UILabel *labelRemark=[[UILabel alloc] initWithFrame:frame];
	labelRemark.textColor = textColor;
	labelRemark.font = Font(size);
	labelRemark.lineBreakMode = NSLineBreakByWordWrapping;
	labelRemark.numberOfLines = 0;
    labelRemark.backgroundColor=BGColor;
    labelRemark.highlightedTextColor=[UIColor grayColor];
	labelRemark.text=text;
	return labelRemark;
}

+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text color:(UIColor *)color size:(NSInteger)size
{
	
	UILabel *labelRemark=[[UILabel alloc] initWithFrame:frame];
	labelRemark.textColor = color;
    labelRemark.text=text;
	labelRemark.font = Font(size);
	labelRemark.lineBreakMode = NSLineBreakByWordWrapping;
	labelRemark.numberOfLines = 0;
    labelRemark.textAlignment=NSTextAlignmentLeft;
    labelRemark.backgroundColor=[UIColor clearColor];
    labelRemark.highlightedTextColor=[UIColor grayColor];
	
	return labelRemark;
}
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text fontSize:(int)fontSize color:(UIColor *)color
{
	UILabel *labelPrice=[[UILabel alloc] initWithFrame:frame];
	labelPrice.textColor = color;
	labelPrice.font = [UIFont fontWithName:@"Arial" size:fontSize];
	labelPrice.lineBreakMode = NSLineBreakByWordWrapping;
	labelPrice.numberOfLines = 0;
    labelPrice.backgroundColor=[UIColor whiteColor];
	labelPrice.text=text;
	return labelPrice;
}
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text fontSize:(int)fontSize color:(UIColor *)color align:(NSString *)align
{
	UILabel *labelPrice=[[UILabel alloc] initWithFrame:frame];
	labelPrice.textColor = color;
	labelPrice.font = Font(fontSize);
	labelPrice.lineBreakMode = NSLineBreakByWordWrapping;
	labelPrice.numberOfLines = 0;
    if([align isEqualToString:@"right"])
    {
        labelPrice.textAlignment=NSTextAlignmentRight;
    }
    else if([align isEqualToString:@"center"])
    {
        labelPrice.textAlignment=NSTextAlignmentCenter;
    }
    else
    {
        labelPrice.textAlignment=NSTextAlignmentLeft;
    }
    
   // labelPrice.backgroundColor=[UIColor whiteColor];
	labelPrice.text=[NSString stringWithFormat:@"%@",text];
	return labelPrice;
}
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text imageName:(NSString *)imageName
{
	UILabel *labelRemark=[[UILabel alloc] initWithFrame:frame];
	
    if (imageName.length>0) {
        labelRemark.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    }
    
	labelRemark.lineBreakMode = NSLineBreakByWordWrapping;
	labelRemark.numberOfLines = 0;
    if (text.length>0) {
        labelRemark.textColor = [UIColor blackColor];
        labelRemark.font = [UIFont fontWithName:@"Arial" size:16];
        labelRemark.text=text;
    }
	
	return labelRemark;
}
+(UITextView *)getTextView:(CGRect)frame   text:(NSString *)text size:(int)size
{
    
    UITextView *textView=[[UITextView alloc] initWithFrame:frame];
    textView.editable=FALSE;
	textView.font=[UIFont fontWithName:@"Arial" size:size];
    textView.text=text;
    return textView;
    
}
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text font:(UIFont *)font
{
    UILabel *labelRemark=[[UILabel alloc] initWithFrame:frame];
    labelRemark.textColor = [UIColor grayColor];
    labelRemark.font = font;
    labelRemark.highlightedTextColor=[UIColor redColor];
    
    labelRemark.lineBreakMode = NSLineBreakByWordWrapping;
    labelRemark.numberOfLines = 0;
    // [labelRemark sizeToFit];
    labelRemark.text=text;
  
    
    //labelRemark.adjustsFontSizeToFitWidth=YES;
    return labelRemark ;
}
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text font:(UIFont *)font color:(UIColor *)color
{
    UILabel *labelRemark=[[UILabel alloc] initWithFrame:frame];
    labelRemark.textColor = color;
    labelRemark.font = font;
    labelRemark.highlightedTextColor=[UIColor redColor];
    
    labelRemark.lineBreakMode = NSLineBreakByWordWrapping;
    labelRemark.numberOfLines = 0;
    // [labelRemark sizeToFit];
    labelRemark.text=text;
    
    
    //labelRemark.adjustsFontSizeToFitWidth=YES;
    return labelRemark ;
}
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text size:(int)size
{
	UILabel *labelRemark=[[UILabel alloc] initWithFrame:frame];
	labelRemark.textColor = [UIColor blackColor];
	labelRemark.font = [UIFont fontWithName:@"Arial" size:size];
      labelRemark.highlightedTextColor=[UIColor redColor];
    
	labelRemark.lineBreakMode = NSLineBreakByWordWrapping;
	labelRemark.numberOfLines = 0;
   // [labelRemark sizeToFit];
	labelRemark.text=text;
    CGRect labelsize=[labelRemark.text boundingRectWithSize:CGSizeMake(frame.size.width, 15000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:size]} context:nil];
    if (labelsize.size.height>frame.size.height)
    labelRemark.frame=CGRectMake(frame.origin.x,frame.origin.y, frame.size.width,  labelsize.size.height);
    
    //labelRemark.adjustsFontSizeToFitWidth=YES;
	return labelRemark ;
}

+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text align:(NSString *)align
{
    if ([text rangeOfString:@".00"].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@".00" withString:@""];
    }
	UILabel *labelPrice=[[UILabel alloc] initWithFrame:frame];
	labelPrice.textColor = [UIColor blackColor];
	labelPrice.font = [UIFont fontWithName:@"Arial" size:15];
	labelPrice.lineBreakMode = NSLineBreakByWordWrapping;
    //labelPrice.backgroundColor=[UIColor whiteColor];
	labelPrice.numberOfLines = 0;
    if([align isEqualToString:@"right"])
    {
        labelPrice.textAlignment=NSTextAlignmentRight;
    }
    else if([align isEqualToString:@"center"])
    {
        labelPrice.textAlignment=NSTextAlignmentCenter;
    }
    else
    {
    labelPrice.textAlignment=NSTextAlignmentLeft;
    }
    
	labelPrice.text=text;
    CGRect labelSize = [labelPrice.text boundingRectWithSize:CGSizeMake(frame.size.width, 15000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:15]} context:nil];
//    CGSize  labelsize=[labelPrice.text sizeWithFont:labelPrice.font constrainedToSize:CGSizeMake(frame.size.width, 15000) lineBreakMode:NSLineBreakByWordWrapping];
    
    if (labelSize.size.height>frame.size.height)
    labelPrice.frame=CGRectMake(frame.origin.x,frame.origin.y, frame.size.width,  labelSize.size.height);
    
	return labelPrice ;
}
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text textSize:(int)size  textColor:(UIColor *)textColor textBgColor:(UIColor *)bgcolor  textAlign:(NSString *)align
{
    if ([text rangeOfString:@".00"].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@".00" withString:@""];
    }
	UILabel *labelPrice=[[UILabel alloc] initWithFrame:frame];
	labelPrice.textColor = textColor;
	labelPrice.font = [UIFont fontWithName:@"Arial" size:size];
	labelPrice.lineBreakMode = NSLineBreakByWordWrapping;
    labelPrice.backgroundColor=bgcolor;
	labelPrice.numberOfLines = 0;
    if([align isEqualToString:@"right"])
    {
        labelPrice.textAlignment=NSTextAlignmentRight;
    }
    else if([align isEqualToString:@"center"])
    {
        labelPrice.textAlignment=NSTextAlignmentCenter;
    }
    
	labelPrice.text=text;
    CGRect labelsize  = [labelPrice.text boundingRectWithSize:CGSizeMake(frame.size.width, 15000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:size]} context:nil];
//    CGSize  labelsize=[labelPrice.text sizeWithFont:labelPrice.font constrainedToSize:CGSizeMake(frame.size.width, 15000) lineBreakMode:NSLineBreakByWordWrapping];
    if (labelsize.size.height>frame.size.height)
    labelPrice.frame=CGRectMake(frame.origin.x,frame.origin.y,frame.size.width,  labelsize.size.height);
	return labelPrice;
}
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text  size:(int)size align:(NSString *)align
{
    if ([text rangeOfString:@".00"].location!=NSNotFound) {
        text=[text stringByReplacingOccurrencesOfString:@".00" withString:@""];
    }
	UILabel *labelPrice=[[UILabel alloc] initWithFrame:frame] ;
	labelPrice.textColor = [UIColor blackColor];
	labelPrice.font = Font(size);
	labelPrice.lineBreakMode = NSLineBreakByWordWrapping;
    labelPrice.backgroundColor=[UIColor whiteColor];
	labelPrice.numberOfLines = 0;
    if([align isEqualToString:@"right"])
    {
        labelPrice.textAlignment=NSTextAlignmentRight;
    }
    else if([align isEqualToString:@"center"])
    {
        labelPrice.textAlignment=NSTextAlignmentCenter;
    }
    
	labelPrice.text=text;
    CGRect labelsize = [labelPrice.text boundingRectWithSize:CGSizeMake(frame.size.width, 15000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:Font(size)} context:nil];
//    CGSize  labelsize=[labelPrice.text sizeWithFont:labelPrice.font constrainedToSize:CGSizeMake(frame.size.width, 15000) lineBreakMode:NSLineBreakByWordWrapping];
    if (labelsize.size.height>frame.size.height)
    labelPrice.frame=CGRectMake(frame.origin.x,frame.origin.y, frame.size.width,  labelsize.size.height);
	return labelPrice;
}
+(UILabel *)getlabel:(CGRect)frame text:(NSString *)text
{
	UILabel *labelRemark=[[UILabel alloc] initWithFrame:frame];
    labelRemark.text=text;
	labelRemark.textColor = [UIColor blackColor];
    labelRemark.backgroundColor=[UIColor clearColor];
	labelRemark.font = [UIFont fontWithName:@"Arial" size:16];
	labelRemark.lineBreakMode = NSLineBreakByWordWrapping;
	labelRemark.numberOfLines = 0;
    CGRect labelsize = [labelRemark.text boundingRectWithSize:CGSizeMake(frame.size.width, 15000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:16]} context:nil];
//    CGSize  labelsize=[labelRemark.text sizeWithFont:labelRemark.font constrainedToSize:CGSizeMake(frame.size.width, 15000) lineBreakMode:NSLineBreakByWordWrapping];
    if (labelsize.size.height>frame.size.height)
    labelRemark.frame=CGRectMake(frame.origin.x,frame.origin.y,frame.size.width,  labelsize.size.height);
    
	return labelRemark;
}



+(UITextField *)getTextFieldInControl:(id)control frame:(CGRect)frame  tag:(NSInteger)tag returnType:(NSString *)returnType
{
    
    UITextField  *TextField=[[UITextField alloc] initWithFrame:frame];
	//TextField.delegate = self;
	TextField.tag=tag;
	TextField.textAlignment = NSTextAlignmentLeft;
	TextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	TextField.returnKeyType = UIReturnKeyNext;
	TextField.font=[UIFont fontWithName:@"Arial" size:16+2];
	TextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	TextField.layer.cornerRadius=2.0f;
    TextField.layer.masksToBounds=YES;
    TextField.layer.borderColor=[[UIColor grayColor] CGColor];
    TextField.layer.borderWidth= 1.0f;
    TextField.backgroundColor=[UIColor whiteColor];
    if ([returnType isEqualToString:@"next"])
    {
        TextField.returnKeyType = UIReturnKeyNext;
    }
    else {
        TextField.returnKeyType = UIReturnKeyDone;
    }
    UIView *leftView=[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 5.0f,30.0f)];
	TextField.leftView=leftView;
    TextField.delegate=control;
	TextField.leftViewMode = UITextFieldViewModeAlways;
	
    
    UIButton* btnDowd= [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDowd setImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
    [btnDowd setFrame:CGRectMake(0,0, 32,32)];
    [btnDowd  addTarget:TextField action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, ScreenW, 32);
    btnDowd.frame = CGRectOffset(btnDowd.frame,ScreenW  - btnDowd.bounds.size.width, 0);
    [view addSubview:btnDowd];
    TextField.inputAccessoryView =view;
     
   
    return TextField;
    
}
+(UITextField *)getTextFieldInControl:(id)control frame:(CGRect)frame  tag:(NSInteger)tag  returnType:(NSString *)returnType text:(NSString *)text placeholder:(NSString *)placeholder
{
    
    UITextField  *TextField=[[UITextField alloc] initWithFrame:frame];
	//TextField.delegate = self;
	TextField.tag=tag;
	TextField.textAlignment = NSTextAlignmentLeft;
	TextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	TextField.returnKeyType = UIReturnKeyNext;
	TextField.font=[UIFont fontWithName:@"Arial" size:16+2];
	TextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	TextField.layer.cornerRadius=2.0f;
    TextField.layer.masksToBounds=YES;
    TextField.layer.borderColor=[[UIColor grayColor] CGColor];
    TextField.layer.borderWidth= 1.0f;
    TextField.backgroundColor=[UIColor whiteColor];
    TextField.text=text;
    TextField.placeholder=placeholder;
     [TextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];//取消自动首字母大写
    if ([returnType isEqualToString:@"next"])
    {
        TextField.returnKeyType = UIReturnKeyNext;
    }
    else {
        TextField.returnKeyType = UIReturnKeyDone;
    }
    UIView *leftView=[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 5.0f,30.0f)];
	TextField.leftView=leftView;
    TextField.delegate=control;
	TextField.leftViewMode = UITextFieldViewModeAlways;
	
    
    UIButton* btnDowd= [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDowd setImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
    [btnDowd setFrame:CGRectMake(0,0, 32,32)];
    [btnDowd  addTarget:TextField action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, ScreenW, 32);
    btnDowd.frame = CGRectOffset(btnDowd.frame, ScreenW - btnDowd.bounds.size.width, 0);
    [view addSubview:btnDowd];
    TextField.inputAccessoryView =view;
    return TextField;
    
}

+(UITextView *)getTextViewInControl:(id)control frame:(CGRect)frame  tag:(NSInteger)tag returnType:(NSString *)returnType
{
    
    UITextView *textView=[[UITextView alloc] initWithFrame:frame];
	textView.delegate = control;
	textView.tag=tag;
	textView.textAlignment = NSTextAlignmentLeft;
	textView.font=[UIFont fontWithName:@"Arial" size:16+2];
	textView.layer.cornerRadius=2.0f;
    textView.layer.masksToBounds=YES;
    textView.layer.borderColor=[[UIColor grayColor] CGColor];
    textView.layer.borderWidth= 1.0f;
    
    if ([returnType isEqualToString:@"next"])
    {
        textView.returnKeyType = UIReturnKeyNext;
    }
    else {
        textView.returnKeyType = UIReturnKeyDone;
    }
    UIButton* btnDowd= [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDowd setImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
    [btnDowd setFrame:CGRectMake(0,0, 32,32)];
    [btnDowd  addTarget:textView action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, ScreenW, 32);
    btnDowd.frame = CGRectOffset(btnDowd.frame, ScreenW - btnDowd.bounds.size.width, 0);
    [view addSubview:btnDowd];
    textView.inputAccessoryView =view;
    return textView;
    
}

+(UITextField *)getTextField:(CGRect)frame  tag:(NSInteger)tag returnType:(NSString *)returnType
{
    
    UITextField  *TextField=[[UITextField alloc] initWithFrame:frame];
	//TextField.delegate = self;
	TextField.tag=tag;
	TextField.textAlignment = NSTextAlignmentLeft;
	TextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	TextField.returnKeyType = UIReturnKeyNext;
	TextField.font=[UIFont fontWithName:@"Arial" size:16+2];
	TextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	TextField.layer.cornerRadius=2.0f;
    TextField.layer.masksToBounds=YES;
    TextField.layer.borderColor=[[UIColor blackColor] CGColor];
    TextField.layer.borderWidth= 1.0f;
     TextField.backgroundColor=[UIColor whiteColor];
    if ([returnType isEqualToString:@"next"]) {
        TextField.returnKeyType = UIReturnKeyNext;
    }
    else {
        TextField.returnKeyType = UIReturnKeyDone;
    }
    UIView *leftView=[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 5.0f,30.0f)];
	TextField.leftView=leftView;
	TextField.leftViewMode = UITextFieldViewModeAlways;
	
    
    UIButton* btnDowd= [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDowd setImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
    [btnDowd setFrame:CGRectMake(0,0, 32,32)];
    [btnDowd  addTarget:TextField action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, ScreenW, 32);
    btnDowd.frame = CGRectOffset(btnDowd.frame, ScreenW - btnDowd.bounds.size.width, 0);
    [view addSubview:btnDowd];
    TextField.inputAccessoryView =view;
    
    return TextField;
    
}
/*+(UISegmentedControl *)getSegmentedControl:(NSArray *)buttonNames
{
    //NSArray *buttonNames = [NSArray arrayWithObjects:type1,type2,type3,type4,type5,nil];
    
    UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:buttonNames];
    segmentedControl.frame=CGRectMake(0, 0, MainS_Width, 36);
    //segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    //segmentedControl.selectedSegmentIndex=UISegmentedControlNoSegment;
    //segmentedControl.segmentedControlStyle = 0;
    segmentedControl.selectedSegmentIndex=0;
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"Arial" size:16], NSFontAttributeName,
                                [UIColor blackColor], NSForegroundColorAttributeName,
                                nil];
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor greenColor] forKey:NSForegroundColorAttributeName];
    [segmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    
    [segmentedControl setBackgroundImage:[UIImage imageNamed:@"buttonGray"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundImage:[UIImage imageNamed:@"buttonBlue"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    return segmentedControl;
}*/

+(UIButton *)getButtonInControl:(id)control frame:(CGRect)frame imageName:(NSString *)imageName title:(NSString *)title clickAction:(SEL)clickAction
{
	UIButton *btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
	if (imageName.length>0)
    {
        [btnCamera setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//		[btnCamera setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
	}
	if (title.length>0)
    {
		[btnCamera setTitle:title forState:UIControlStateNormal];
        [btnCamera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnCamera.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        btnCamera.titleLabel.numberOfLines=0;
//        btnCamera.layer.cornerRadius = 3; // this value vary as per your desire
//        btnCamera.layer.masksToBounds = YES;
         btnCamera.titleLabel.font=[UIFont fontWithName:@"Arial" size:16];
	}
    
	btnCamera.frame = frame;
	[btnCamera addTarget:control action:clickAction forControlEvents:UIControlEventTouchUpInside];
	return btnCamera;
}
+(UISwitch *)getSwitchInControl:(id)control frame:(CGRect)frame clickAction:(SEL)clickAction
{
    UISwitch *switchCtrl = [[UISwitch alloc]initWithFrame:frame];
    
    [switchCtrl setTag:1];
    [switchCtrl addTarget:control action:clickAction forControlEvents:UIControlEventValueChanged];
    return  switchCtrl;
    
    
}
+(UIButton *)getButtonInControl:(id)control frame:(CGRect)frame TitleImageName:(NSString *)imageName title:(NSString *)title tag:(int)tag clickAction:(SEL)clickAction{
    UIButton *btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    if (imageName.length>0)
    {
        [btnCamera setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    if (title.length>0)
    {
        [btnCamera setTitle:title forState:UIControlStateNormal];
        [btnCamera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        btnCamera.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        btnCamera.titleLabel.numberOfLines=1;
        btnCamera.titleLabel.adjustsFontSizeToFitWidth=YES;
        btnCamera.titleLabel.font=[UIFont fontWithName:@"Arial" size:16];
        
        btnCamera.layer.cornerRadius = 3; // this value vary as per your desire
        btnCamera.clipsToBounds = YES;
        
        
    }
    
    btnCamera.tag=tag;
    btnCamera.frame = frame ;
    [btnCamera addTarget:control action:clickAction forControlEvents:UIControlEventTouchUpInside];
    return btnCamera;
}
+(UIButton *)getButtonInControl:(id)control frame:(CGRect)frame imageName:(NSString *)imageName title:(NSString *)title  tag:(int)tag clickAction:(SEL)clickAction
{
	UIButton *btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
	if (imageName.length>0)
    {
		[btnCamera setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
	}
	if (title.length>0)
    {
		[btnCamera setTitle:title forState:UIControlStateNormal];
        [btnCamera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnCamera.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        btnCamera.titleLabel.numberOfLines=0;
        btnCamera.titleLabel.adjustsFontSizeToFitWidth=YES;
        btnCamera.titleLabel.font=[UIFont fontWithName:@"Arial" size:16];
       
            btnCamera.layer.cornerRadius = 3; // this value vary as per your desire
            btnCamera.clipsToBounds = YES;
        
        
	}
    
    btnCamera.tag=tag;
	btnCamera.frame = frame ;
	[btnCamera addTarget:control action:clickAction forControlEvents:UIControlEventTouchUpInside];
	return btnCamera;
}
+(UIButton *)getButtonInControl:(id)control frame:(CGRect)frame  title:(NSString *)title align:(NSString *)align  color:(UIColor *)color fontsize:(int)fontsize tag:(int)tag clickAction:(SEL)clickAction imageName:(NSString *)imageName
{
    UIButton *btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    if (imageName.length>0)
    {
        [btnCamera setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    if (title.length>0)
    {
        [btnCamera setTitle:title forState:UIControlStateNormal];
        [btnCamera setTitleColor:color forState:UIControlStateNormal];
        btnCamera.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        btnCamera.titleLabel.numberOfLines=0;
        btnCamera.titleLabel.adjustsFontSizeToFitWidth=YES;
        // btnCamera.titleLabel.backgroundColor=UIColorFromRGB(0xFCFCFC);
        btnCamera.titleLabel.font=Font(fontsize);
        if ([align isEqualToString:@"left"]) {
            btnCamera.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
        else  if ([align isEqualToString:@"right"]) {
            btnCamera.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
        
        else {
            btnCamera.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        }
        btnCamera.layer.cornerRadius = 3; // this value vary as per your desire
        btnCamera.clipsToBounds = YES;
        
    }
    
    btnCamera.tag=tag;
    btnCamera.frame = frame ;
    [btnCamera addTarget:control action:clickAction forControlEvents:UIControlEventTouchUpInside];
    return btnCamera;
}

+(UIButton *)getButtonInControl:(id)control frame:(CGRect)frame  title:(NSString *)title align:(NSString *)align  color:(UIColor *)color fontsize:(int)fontsize tag:(int)tag clickAction:(SEL)clickAction
{
	UIButton *btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnCamera.backgroundColor = [UIColor whiteColor];
    
	if (title.length>0)
    {
		[btnCamera setTitle:title forState:UIControlStateNormal];
        [btnCamera setTitleColor:color forState:UIControlStateNormal];
        btnCamera.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        btnCamera.titleLabel.numberOfLines=0;
        btnCamera.titleLabel.adjustsFontSizeToFitWidth=YES;
//        btnCamera.titleLabel.backgroundColor = UIColorFromRGB(0xFCFCFC);
        btnCamera.titleLabel.font=Font(fontsize);
        if ([align isEqualToString:@"left"]) {
             btnCamera.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
        else  if ([align isEqualToString:@"right"]) {
            btnCamera.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
        
        else {
            btnCamera.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        }
//        btnCamera.layer.cornerRadius = 3; // this value vary as per your desire
//        btnCamera.clipsToBounds = YES;
      
	}
    
    btnCamera.tag=tag;
	btnCamera.frame = frame ;
	[btnCamera addTarget:control action:clickAction forControlEvents:UIControlEventTouchUpInside];
	return btnCamera;
}

+(UISearchBar *)getSearchBarInControl:(id)control frame:(CGRect)frame placeholder:(NSString *)placeholder tag:(int)tag
{
   
    
    UISearchBar *sBar=[[UISearchBar alloc] initWithFrame:frame];
    sBar.delegate=control;
   
   sBar.autocorrectionType = UITextAutocorrectionTypeNo;
    sBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        sBar.barTintColor=navigationColor;
        sBar.searchBarStyle = UISearchBarStyleMinimal;
        
        for (UIView *subView in sBar.subviews)
        {
            for (UIView *secondLevelSubview in subView.subviews){
                if ([secondLevelSubview isKindOfClass:[UITextField class]])
                {
                    UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                    
                    //set font color here
                    searchBarTextField.textColor =[UIColor blackColor];
                    
                    break;
                }
            }
        }
        
    }
    else
    {
        sBar.tintColor=navigationColor;
        [sBar setBackgroundImage:[UIImage new]];
        [sBar setTranslucent:YES];
    }
     sBar.placeholder=placeholder;
    sBar.showsCancelButton=false;
    UIButton* btnDowd= [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDowd setImage:[UIImage imageNamed:@"down.png"] forState:UIControlStateNormal];
    [btnDowd setFrame:CGRectMake(0,0, 32,32)];
    [btnDowd  addTarget:sBar action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, ScreenW, 32);
    btnDowd.frame = CGRectOffset(btnDowd.frame, ScreenW - btnDowd.bounds.size.width, 0);
    [view addSubview:btnDowd];
    sBar.inputAccessoryView =view;
    
    
    return sBar;
}
/*+(UISegmentedControl *)getSegmentedControlIn:(id)control frame:(CGRect)frame buttonNames:(NSArray *)buttonNames  action:(SEL)action
{
    //NSArray *buttonNames = [NSArray arrayWithObjects:type1,type2,type3,type4,type5,nil];
    
    UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:buttonNames];
    segmentedControl.frame=frame;
    segmentedControl.tintColor=navigationColor;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"Arial" size:16], NSFontAttributeName,
                                [UIColor blackColor], NSForegroundColorAttributeName,
                                nil];
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
    [segmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    
    segmentedControl.selectedSegmentIndex=0;
    [segmentedControl addTarget:control action:action forControlEvents:UIControlEventValueChanged];
    [segmentedControl setBackgroundImage:[UIImage imageNamed:@"buttonGray"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundImage:[UIImage imageNamed:@"buttonBlue"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    // [segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor redColor] forKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    
    
    return  segmentedControl;
    
}*/

+ (UIImage *) getThumbnailImage:(UIImage *)image width:(int)width height:(int)height
{
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  [UIImage imageWithData:UIImageJPEGRepresentation(newImage,0.5f)];
}


+(void)singleTap:(UITapGestureRecognizer*)sender
{
    NSLog(@"singleTap");
    //do what you need.
}

/**
 *@brief 输入文字判断文字中是否有链接返回文字（用于解决帖子或活动详情出现链接计算文字高度问题）
 */
-(NSString *)BrianPublicStringWithUrlString:(NSString *)content
{
    _tempString  = [NSMutableString stringWithString:content];
    _urlArray = [NSMutableArray array];
    _dataArr = [NSMutableArray array];
    _rangeArr = [NSMutableArray array];
    [self getFirstUrlFromString:content];
    
    return _tempString;
}
- (void)getFirstUrlFromString:(NSString *)searchText {
    
    NSRange range = [searchText rangeOfString:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)" options:NSRegularExpressionSearch];
    
    if (range.location != NSNotFound) {
        NSString *url = [searchText substringWithRange:range];
        if ([url containsString:@"wancheleyuan.com"]) {
            [_urlArray addObject:url];
            [_dataArr addObject:@"网页链接"];
            [_rangeArr addObject:NSStringFromRange(range)];
            NSMutableString *string = [NSMutableString stringWithString:searchText];
            [string replaceCharactersInRange:range withString:@"网页链接"];
            [_tempString replaceCharactersInRange:range withString:@"网页链接"];
            [self getFirstUrlFromString:string];
        }
    }
}


@end
