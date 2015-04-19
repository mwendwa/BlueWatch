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
#import "SNMainTableViewControllerRecord.h"
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVFoundation.h>

#define SEND_LOCATION @"sendLocation"
#define SEND_RECORDING @"sendRecording"
#define PARENT_1 @"Parent1"
#define PARENT_2 @"Parent2"
#define APP_TITLE @"Settings"
#define AUDIO_FILE @"SafeNet.m4a"

@interface SNSidebarViewController () <UIGestureRecognizerDelegate, UITableViewDelegate, UIAlertViewDelegate, MFMessageComposeViewControllerDelegate, AVAudioRecorderDelegate>

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) SNParentProfile *parent1;
@property (nonatomic, strong) SNParentProfile *parent2;
@property (nonatomic, strong) SNTeenProfile *teen;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *locationAddress;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

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
    
    UILabel *tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
    tlabel.text = APP_TITLE;
    tlabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0];
    tlabel.textColor = [UIColor grayColor];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth = YES;
    tlabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = tlabel;
    
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
    
    _parent1 = [SNParentProfile savedParent:PARENT_1];
    _parent2 = [SNParentProfile savedParent:PARENT_2];
    _teen = [SNTeenProfile savedTeen];
    
    _menuItems = @[@"drive", @"parent", @"teen", @"location", @"record", @"rate", @"about"];
    
    NSLog(@"[%@ viewDidLoad]",self);
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    _parent1 = [SNParentProfile savedParent:PARENT_1];
    _parent2 = [SNParentProfile savedParent:PARENT_2];
    _teen = [SNTeenProfile savedTeen];
    
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[_menuItems objectAtIndex:indexPath.row] capitalizedString];
  
    // Send the teen's location to parents.  I really want this done in the didSelectRowForIndexPath method, but can't figure
    // out why it's not being triggered. Ugh!
    if ([segue.identifier isEqualToString:SEND_LOCATION]) {
        NSLog(@"Send teen location to: %@, %@", _parent1.description, _parent2.description);
        NSLog(@"%@ is at: %@", _teen.name, _teen.myLocation);
        
        NSString *alertTitle = NSLocalizedString(@"Send Location", @"Send Location");
        NSString *alertMessage = _teen.myLocation;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                 message:alertMessage
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                           
                                       }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                       NSString *msgBody = [NSString stringWithFormat:@"SafeNet Location Notification: \n%@\n%@", _teen.name, _teen.myLocation];
                                       [self sendSMS:msgBody recipientList:[NSArray arrayWithObjects:_parent1.number,_parent2.number, nil]];
                                   }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    // send recorded conversation
    if ([segue.identifier isEqualToString:SEND_RECORDING]) {
        NSLog(@"Send recording");
        
        NSString *alertTitle = NSLocalizedString(@"Send Recording and Location", @"Send Recording and Location");
        NSString *alertMessage = [NSString stringWithFormat:@"%@", AUDIO_FILE];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                 message:alertMessage
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                           
                                       }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                       NSString *msgBody = [NSString stringWithFormat:@"SafeNet Audio Notification: \n%@\n%@", _teen.name, _teen.myLocation];
                                       [self sendAudio:msgBody recipientList:[NSArray arrayWithObjects:_parent1.number,_parent2.number, nil]];

                                   }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
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

- (void) handleTap:(UIGestureRecognizer *)recognizer
{
    NSLog(@"handleTap: Send teen location to parent");
}

- (void) tableView:(UITableView *)tableView didSeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Send teen location to: %@", _parent1);
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - Send SMS

- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = bodyOfMessage;
        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)sendAudio:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    NSString *filename = AUDIO_FILE;
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory = [pathArray objectAtIndex:0];
    NSString *soundPath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath isDirectory:NO];
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        
        if([MFMessageComposeViewController canSendText] &&
           [MFMessageComposeViewController canSendAttachments] &&
           [MFMessageComposeViewController isSupportedAttachmentUTI:@"com.apple.m4a"])
        {
            controller.body = bodyOfMessage;
            controller.recipients = recipients;
            [controller addAttachmentURL:soundURL withAlternateFilename:nil];
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (result == MessageComposeResultCancelled)
            NSLog(@"Message cancelled");
        else if (result == MessageComposeResultSent)
            NSLog(@"Message sent");
        else
            NSLog(@"Message failed");
    }];
}

@end
