//
//  SNButtonCell.h
//  BlueWatch
//
//  Created by Eugene Alute Mwendwa on 8/10/15.
//  Copyright (c) 2015 SafeNet Industries. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNButtonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;

@end
