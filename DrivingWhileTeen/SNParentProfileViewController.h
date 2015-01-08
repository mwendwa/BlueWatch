//
//  SNParentProfileViewController.h
//  DrivingWhileTeen
//
//  Created by Eugene Alute Mwendwa on 12/1/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNParentProfile.h"

@interface SNParentProfileViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, strong) SNParentProfile *parent;

@end
