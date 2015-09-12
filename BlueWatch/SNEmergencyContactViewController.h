//
//  SNEmergencyContactViewController.h
//  BlueWatch
//
//  Created by Eugene Alute Mwendwa on 08/31/15.
//  Copyright (c) 2015 SafeNet Industries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNParentProfile.h"

@interface SNEmergencyContactViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, strong) SNParentProfile *p1;
@property (nonatomic, strong) SNParentProfile *p2;

@end
