//
//  SNSidebarViewController.m
//  DrivingWhileTeen
//
//  Modified by Eugene Alute Mwendwa on 10/10/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//
//  Created by Simon on 29/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "SNSidebarViewController.h"
#import "SWRevealViewController.h"
#import "SNParentProfile.h"
#import "SNTeenProfile.h"
#import <MessageUI/MessageUI.h>
#define kSendLocation   @"sendLocation"

@interface SNSidebarViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) SNParentProfile *parent;
@property (nonatomic, strong) SNTeenProfile *teen;

@end

@implementation SNSidebarViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
    
    [self.tableView setAllowsSelection:YES];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    _parent = [SNParentProfile savedParent];
    _teen = [SNTeenProfile savedTeen];
    
    _menuItems = @[@"title", @"drive", @"parent", @"teen", @"location", @"record", @"about"];
    NSLog(@"[%@ viewDidLoad]",self);
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[_menuItems objectAtIndex:indexPath.row] capitalizedString];
  

    // Send the teen's location to parents.  I really want this done in the didSelectRowForIndexPath method, but can't figure
    // out why it's not being triggered. Ugh!
    if ([segue.identifier isEqualToString:kSendLocation]) {
        NSLog(@"Send teen location to: %@", _parent.description);
        NSLog(@"Teen is at: %@", _teen.location);
        
        [self sendSMS:@"Location..." recipientList:[NSArray arrayWithObjects:_parent.number, nil]];
    }
    
    // Manage the view transition and tell SWRevealViewController the new front view controller for display.
    // We reuse the navigation controller and replace the view controller with destination view controller.
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // add tap gesture
    //UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    //tapRecognizer.numberOfTapsRequired = 1;
    //tapRecognizer.numberOfTouchesRequired = 1;
    //cell.userInteractionEnabled = YES;
    //[cell addGestureRecognizer:tapRecognizer];
    
    return cell;
}

- (void) handleTap:(UIGestureRecognizer *)recognizer {
    NSLog(@"handleTap: Send teen location to parent");
}

- (void) tableView:(UITableView *)tableView didSeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Send teen location to: %@", _parent);
    
    //if ([indexPath isEqual:[tableView indexPathForCell:self.sendLocationButtonCell]]) {
      //  NSLog(@"Send teen location to parent");
    //}
}

- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = bodyOfMessage;
        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        [self presentModalViewController:controller animated:YES];
    }    
}

@end
