//
//  WXListComponent+Extension.m
//  WeexDemo
//
//  Created by 吴述雄 on 2019/2/12.
//  Copyright © 2019 wusx. All rights reserved.
//

#import "WXListComponent+Extension.h"
#import <objc/runtime.h>

@interface WXListComponent ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, copy) NSString *editType;

@end

@implementation WXListComponent (Extension)

- (void)setEditType:(NSString *)editType {
    objc_setAssociatedObject(self, @selector(editType), editType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)editType {
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)load {
    [self weex_swizzle:[self class] Method:@selector(initWithRef:type:styles:attributes:events:weexInstance:) withMethod:@selector(new1_initWithRef:type:styles:attributes:events:weexInstance:)];
    [self weex_swizzle:[self class] Method:@selector(updateAttributes:) withMethod:@selector(new1_updateAttributes:)];
    [self weex_swizzle:[self class] Method:@selector(viewDidLoad) withMethod:@selector(new1_viewDidLoad)];
}

-(instancetype)new1_initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance {
    id ret = [self new1_initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (attributes[@"editType"]) {
        self.editType = attributes[@"editType"];
    }
    return ret;
}

- (void)new1_updateAttributes:(NSDictionary *)attributes {
    [self new1_updateAttributes:attributes];
    
    if (attributes[@"editType"]) {
        UITableView *tableView = (UITableView *)self.view;
        if ([attributes[@"editType"] isEqualToString:@"move"]) {
            tableView.editing = YES;
        }else if ([attributes[@"editType"] isEqualToString:@"delete"]){
            
        }else if ([attributes[@"editType"] isEqualToString:@"none"]){
            tableView.editing = NO;
        }
    }
}

- (void)new1_viewDidLoad {
    [self new1_viewDidLoad];
    
    if (self.editType) {
        UITableView *tableView = (UITableView *)self.view;
        tableView.delegate = self;
        tableView.dataSource = self;
    }

}

#pragma mark -- delegate
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    [self fireEvent:@"moveHandler" params:@{
                                            @"fromSection":@(sourceIndexPath.section),
                                            @"fromIndex":@(sourceIndexPath.row),
                                            @"toSection":@(destinationIndexPath.section),
                                            @"toIndex":@(destinationIndexPath.row),
                                            }];
}

@end