//
//  CurrentLocationTableViewCell.m
//  RestAssured
//
//  Created by pc on 2018/5/15.
//  Copyright © 2018年 RunWise. All rights reserved.
//

#import "CurrentLocationTableViewCell.h"
#import "PublicTool.h"
@implementation CurrentLocationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.icon.image = [PublicTool wx_imageNamed:@"location_true"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
