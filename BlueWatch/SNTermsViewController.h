//
//  SNMainTableViewController.h
//  BlueWatch
//
//  Created by Eugene Alute Mwendwa on 9/22/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNEmergencyContactViewController.h"

@protocol TermsViewProtocol <NSObject>

- (void) declineAndAcceptTermsView;

@end

@interface SNTermsViewController : UITableViewController

@property (nonatomic, weak) id <TermsViewProtocol> delegate;
@property (nonatomic, retain) SNEmergencyContactViewController *emergencyContactView;

@end
