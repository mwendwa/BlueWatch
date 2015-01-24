//
//  SNMainTableViewController.m
//  drivingwhileteen
//
//  Created by Eugene Alute Mwendwa on 9/22/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import "SNMainTableViewController.h"
#import "SWRevealViewController.h"
#import "SNTeenProfile.h"
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>

#define kTitle @"Driving While Teen"

@interface SNMainTableViewController () <CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSDate *timeofDay;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) NSArray *locationAddress;
@property (nonatomic, strong) SNTeenProfile *teen;

@end

@implementation SNMainTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
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
    
    self.teen = [SNTeenProfile savedTeen];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.sidebarButton.target = self.revealViewController;
    self.sidebarButton.action = @selector(revealToggle:);
    
    _menuItems = @[@"pullover", @"window", @"engine", @"domelight", @"smartphone",  @"hands", @"speak", @"obey", @"answer", @"consent", @"badge"];
    
    // set the location
    if ([CLLocationManager locationServicesEnabled]) {
        
        if (nil == self.locationManager)
            self.locationManager = [[CLLocationManager alloc] init];
    
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 500;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            [self.locationManager requestWhenInUseAuthorization];
    
        [self.locationManager startUpdatingLocation];

        // reverse geocode location
        if (!self.geocoder)
            self.geocoder = [[CLGeocoder alloc] init];
        
        [self.geocoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray* placemarks, NSError *error) {
            NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
            if (nil == error && [placemarks count] > 0) {
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[placemarks count]];
                for (CLPlacemark *placemark in placemarks) {
                    [tempArray addObject:[NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@\n",
                                          placemark.subThoroughfare, placemark.thoroughfare,
                                          placemark.postalCode, placemark.locality,
                                          placemark.administrativeArea,
                                          placemark.country]];
                }
                _locationAddress = [tempArray copy];
                _teen.address = [tempArray copy];
                [_teen save];
                NSLog(@"I am currently at %@", _teen.address);
            }
            else {
                _locationAddress = nil;
                NSLog(@"Error: %@", error.debugDescription);
            }
         }];
    }
    
    NSLog(@"[%@ viewDidLoad]",self);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Location manager delegate methods

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    NSLog(@"Error: %@",error.description);
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, save location.
        _teen.location = location;
        [_teen save];
        
        // send location to parent
        //[self sendSMS:@"Location..." recipientList:[NSArray arrayWithObjects:_parent1.number,_parent2.number, nil]];
        
        NSLog(@"Saved teen location at: %@", _teen.location);
    }
    NSLog(@"%@", [locations lastObject]);
}

- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = bodyOfMessage;
        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        [self presentViewController:self animated:YES completion:nil];
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
    
    return cell;
}

@end
