//
//  SNParentProfileViewController.m
//  BlueWatch
//
//  Created by Eugene Alute Mwendwa on 12/1/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import "SNEmergencyContactViewController.h"
#import "SWRevealViewController.h"
#import "SNTableViewCell.h"

#define kCellIdentifier @"SNTableViewCell"
#define PARENT_1 @"Parent1"
#define PARENT_2 @"Parent2"
#define APP_TITLE @"Emergency Contact"
#define START_BLUEWATCH @"startBlueWatch"

@interface SNEmergencyContactViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSArray *thumbNails;
@property (nonatomic, strong) UITextField *selectedTextField;
@property (nonatomic) BOOL isEditing;

@end

@implementation SNEmergencyContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
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
    
    SNParentProfile *sp1 = [SNParentProfile savedParent:PARENT_1];
    SNParentProfile *sp2 = [SNParentProfile savedParent:PARENT_2];
    self.p1 = [[SNParentProfile alloc] init];
    self.p2 = [[SNParentProfile alloc] init];

    if (nil == sp1) {
        self.p1.name = @"Jon Doe";
        self.p1.number = @"555-555-5555";
        self.p1.email = @"jon.doe@email.com";
        NSLog(@"[%@ Parent Profile]", self.p1.description);
    } else {
        self.p1.name = sp1.name;
        self.p1.number = sp1.number;
        self.p1.email = sp1.email;
        NSLog(@"[%@ Saved Parent Profile]", self.p1.description);
    }
    
    if (nil == sp2) {
        self.p2.name = @"Jane Doe";
        self.p2.number = @"444-444-4444";
        self.p2.email = @"jane.doe@email.com";
        NSLog(@"[%@ Parent Profile]", self.p2.description);
    } else {
        self.p2.name = sp2.name;
        self.p2.number = sp2.number;
        self.p2.email = sp2.email;
        NSLog(@"[%@ Saved Parent Profile]", self.p2.description);
    }
    
    [self setTextFieldEditing:NO];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    _menuItems = @[@"name", @"mobile", @"email"];
    _thumbNails = [NSArray arrayWithObjects:@"edit_user-red-50.png",@"phone2-red-50.png",@"email-red-50.png",nil];

    NSLog(@"[%@ viewDidLoad]",self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.menuItems count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 0)
        return @"Emergency Contact 1";
    if(section == 1)
        return @"Emergency Contact 2";
    
    return @"Emergency Contact";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SNTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.textFieldValue.delegate = self;
    cell.textFieldValue.tag = indexPath.row + (indexPath.section * 3);
    NSLog(@"section: %li row: %li tag: %li", (long)indexPath.section, (long)indexPath.row, (long)cell.textFieldValue.tag);
    
    // there should only be 3 elements per section
    if (indexPath.section == 0) {
        switch (cell.textFieldValue.tag) {
            case 0: // 0 + (0 * 0)
                cell.imageView.image = [UIImage imageNamed:[self.thumbNails objectAtIndex:indexPath.row]];
                cell.textFieldValue.text = self.p1.name;
                break;
            case 1: // 1 + (0 * 0)
                cell.imageView.image = [UIImage imageNamed:[self.thumbNails objectAtIndex:indexPath.row]];
                cell.textFieldValue.text = self.p1.number;
                break;
            case 2: // 2 + (0 * 0)
                cell.imageView.image = [UIImage imageNamed:[self.thumbNails objectAtIndex:indexPath.row]];
                cell.textFieldValue.text = self.p1.email;
                break;
            default:
                break;
        }
    } else {    // section = 1
        switch (cell.textFieldValue.tag) {
            case 3: // 0 + (3 * 1)
                cell.imageView.image = [UIImage imageNamed:[self.thumbNails objectAtIndex:indexPath.row]];
                cell.textFieldValue.text = self.p2.name;
                break;
            case 4: // 1 + (3 * 1)
                cell.textFieldValue.tag = indexPath.row + indexPath.section + 5;
                cell.imageView.image = [UIImage imageNamed:[self.thumbNails objectAtIndex:indexPath.row]];
                cell.textFieldValue.text = self.p2.number;
                break;
            case 5: // 2 + (3 * 1)
                cell.imageView.image = [UIImage imageNamed:[self.thumbNails objectAtIndex:indexPath.row]];
                cell.textFieldValue.text = self.p2.email;
                break;
            default:
                break;
        }
    }
    return cell;
}

#pragma mark - Set Editing

- (void)setTextFieldEditing:(BOOL)editing {
    _isEditing = editing;
    UIBarButtonItem *barButton = nil;
    
    if (editing) {
        barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                 target:self
                                                                 action:@selector(barButtonPressed:)];
    } else {
        barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                 target:self
                                                                 action:@selector(barButtonPressed:)];
    }
    
    self.navigationItem.rightBarButtonItem = barButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:176.0f/255.0f green:37.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
    
    if (!editing) {
        [_selectedTextField resignFirstResponder];
    }
    
}

- (void)barButtonPressed:(UIBarButtonItem *)button {
    [self setTextFieldEditing:!_isEditing];
    if (!_isEditing) {
        [_p1 save:PARENT_1];
        [_p2 save:PARENT_2];
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunchedOnce"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"Emergency contacts saved - now start blueWatch");
        [self performSegueWithIdentifier:START_BLUEWATCH sender: button];
        //[self dismissEmergencyContactView];
    }
}

- (void)dismissEmergencyContactView
{
    //NSLog(@"Emergency contacts saved - now start blueWatch");
    //[self performSegueWithIdentifier:START_BLUEWATCH sender: sender];
    
    //SWRevealViewController *vc = [[SWRevealViewController alloc] init];
    //[self presentViewController:vc animated:YES completion:^{
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunchedOnce"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
    //}];
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //SWRevealViewController *vc = (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"blueWatch"];
    //[vc setModalPresentationStyle:UIModalPresentationFullScreen];
    //[self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Perform segues

- (void)prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    if ([segue.identifier isEqualToString:START_BLUEWATCH]) {
        UINavigationController *destViewController = (UINavigationController *)segue.destinationViewController;
        [self.navigationController  presentViewController:destViewController animated:YES completion:nil];
        
        //UIViewController *destController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"parentProfile"];
        //UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:destController];
        //[self.navigationController presentViewController:navigation animated:YES completion:nil];
        
    }
    
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSLog(@"textFieldShouldReturn");
    return TRUE;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldShouldBeginEditing");
    return _isEditing;
    //textField.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    //[self.tableView scrollRectToVisible:textField.frame animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _selectedTextField = textField;
    [self.tableView scrollRectToVisible:textField.frame animated:YES];
    NSLog(@"textFieldDidBeginEditing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"tag: %li", (long)textField.tag);
    switch (textField.tag) {
        case 0:{
            self.p1.name = textField.text;
            break;
        }
        case 1:{
            self.p1.number = textField.text;
            break;
        }
        case 2:{
            self.p1.email = textField.text;
            break;
        }
        case 3:{
            self.p2.name = textField.text;
            break;
        }
        case 7:{
            self.p2.number = textField.text;
            break;
        }
        case 5:{
            self.p2.email = textField.text;
            break;
        }
            
        default:
            break;
    }
    _selectedTextField = nil;
    NSLog(@"textFieldDidEndEditing");
}

@end
