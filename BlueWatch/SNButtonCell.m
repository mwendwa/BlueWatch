//
//  SNButtonCell.m
//  BlueWatch
//
//  Created by Eugene Alute Mwendwa on 8/10/15.
//  Copyright (c) 2015 SafeNet Industries. All rights reserved.
//

#import "SNButtonCell.h"

@implementation SNButtonCell
@synthesize acceptButton = _acceptButton;
@synthesize declineButton = _declineButton;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
