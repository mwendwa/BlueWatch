//
//  SNParentProfileViewController.m
//  DrivingWhileTeen
//
//  Created by Eugene Alute Mwendwa on 12/1/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import "SNParentProfileViewController.h"
#import "SWRevealViewController.h"
#import "SNTableViewCell.h"

#define kCellIdentifier @"SNTableViewCell"
#define kParent1 @"Parent1"
#define kParent2 @"Parent2"
#define kTitle @"Parent Profile"

@interface SNParentProfileViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSArray *thumbNails;
@property (nonatomic, strong) UITextField *selectedTextField;
@property (nonatomic) BOOL isEditing;

@end

@implementation SNParentProfileViewController

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
    
    SNParentProfile *sp1 = [SNParentProfile savedParent:kParent1];
    SNParentProfile *sp2 = [SNParentProfile savedParent:kParent2];
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
        return @"Parent/Gaurdian 1";
    if(section == 1)
        return @"Parent/Gaurdian 2";
    
    return @"Parent/Gaurdian";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SNTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.textFieldValue.delegate = self;
    cell.textFieldValue.tag = indexPath.row + (indexPath.section * 3);
    NSLog(@"section: %li row: %li tag: %li", indexPath.section, indexPath.row, (long)cell.textFieldValue.tag);
    
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
        [_p1 save:kParent1];
        [_p2 save:kParent2];
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

/*
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    textField.backgroundColor = [UIColor whiteColor];
    NSLog(@"textFieldShouldEndEditing");
    return _isEditing;
}
 */

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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
