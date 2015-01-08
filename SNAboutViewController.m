//
//  SNAboutViewController.m
//  DrivingWhileTeen
//
//  Created by Eugene Alute Mwendwa on 1/6/15.
//  Copyright (c) 2015 SafeNet Industries. All rights reserved.
//

#import "SNAboutViewController.h"
#import "SWRevealViewController.h"

@interface SNAboutViewController ()

@end

@implementation SNAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    //self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    
    NSLog(@"[%@ viewDidLoad]",self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
