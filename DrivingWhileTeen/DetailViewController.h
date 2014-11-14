//
//  DetailViewController.h
//  DrivingWhileTeen
//
//  Created by Eugene Alute Mwendwa on 11/14/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

