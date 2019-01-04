//
//  CurrentLocationTableViewCell.m
//  RestAssured
//
//  Created by pc on 2018/5/15.
//  Copyright © 2018年 RunWise. All rights reserved.
//

#import "WeexCurrentLocationTableViewCell.h"
#import "WeexPublicTool.h"
@implementation WeexCurrentLocationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.icon.image = [WeexPublicTool wx_imageNamed:@"location_true"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
