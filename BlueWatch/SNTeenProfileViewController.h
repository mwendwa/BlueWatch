//
//  SNTeenProfileViewController.h
//  BlueWatch
//
//  Created by Eugene Alute Mwendwa on 1/5/15.
//  Copyright (c) 2015 SafeNet Industries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTeenProfile.h"

@interface SNTeenProfileViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, strong) SNTeenProfile *teen;

@end
