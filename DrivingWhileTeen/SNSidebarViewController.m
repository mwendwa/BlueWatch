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

#define kSendLocation @"sendLocation"
#define kParent1 @"Parent1"
#define kParent2 @"Parent2"
#define kTitle @"Settings"

@interface SNSidebarViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) SNParentProfile *parent1;
@property (nonatomic, strong) SNParentProfile *parent2;
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
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
    tlabel.text = kTitle;
    tlabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0];
    tlabel.textColor=[UIColor grayColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    
    // emboss so that the label looks OK
    [tlabel setShadowColor:[UIColor darkGrayColor]];
    [tlabel setShadowOffset:CGSizeMake(0, -0.5)];
    self.navigationItem.titleView = tlabel;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
    
    [self.tableView setAllowsSelection:YES];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    _parent1 = [SNParentProfile savedParent:kParent1];
    _parent2 = [SNParentProfile savedParent:kParent2];
    _teen = [SNTeenProfile savedTeen];
    
    _menuItems = @[@"drive", @"parent", @"teen", @"location", @"record", @"about"];
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
        NSLog(@"Send teen location to: %@", _parent1.description);
        NSLog(@"Teen is at: %@", _teen.location);
        
        //[self sendSMS:@"Location..." recipientList:[NSArray arrayWithObjects:_parent1.number, nil]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sending Location:" message:_teen.myLocation delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        // optional - add more buttons:
        [alert addButtonWithTitle:@"OK"];
        [alert setTag:1];
        [alert show];
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
    NSLog(@"Send teen location to: %@", _parent1);
    
    //if ([indexPath isEqual:[tableView indexPathForCell:self.sendLocationButtonCell]]) {
      //  NSLog(@"Send teen location to parent");
    //}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Index =%ld",buttonIndex);
    if (alertView.tag == 1) {
        if (buttonIndex == 0)
        {
            NSLog(@"You have clicked Cancel");
        }
        else if(buttonIndex == 1)
        {
            NSLog(@"You have clicked OK");
            [self sendSMS:self.teen.myLocation recipientList:[NSArray arrayWithObjects:_parent1.number,_parent2.number, nil]];
        }
    }
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

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissModalViewControllerAnimated:YES];
    
    if (result == MessageComposeResultCancelled)
        NSLog(@"Message cancelled");
        else if (result == MessageComposeResultSent)
            NSLog(@"Message sent");
            else
                NSLog(@"Message failed");
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
