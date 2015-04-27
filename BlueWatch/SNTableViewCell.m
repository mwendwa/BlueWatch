//
//  SNTableViewCell.m
//  BlueWatch
//
//  Created by Eugene Alute Mwendwa on 12/4/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import "SNTableViewCell.h"

@implementation SNTableViewCell
@synthesize textFieldValue = _textFieldValue;
@synthesize imageView = _imageView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
