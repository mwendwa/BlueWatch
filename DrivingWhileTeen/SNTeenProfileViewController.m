//
//  SNTeenProfileViewController.m
//  DrivingWhileTeen
//
//  Created by Eugene Alute Mwendwa on 1/5/15.
//  Copyright (c) 2015 SafeNet Industries. All rights reserved.
//

#import "SNTeenProfileViewController.h"
#import "SWRevealViewController.h"
#import "SNTableViewCell.h"

#define kCellIdentifier @"SNTableViewCell"

@interface SNTeenProfileViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSArray *thumbNails;
@property (nonatomic, strong) UITextField *selectedTextField;
@property (nonatomic) BOOL isEditing;

@end

@implementation SNTeenProfileViewController

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
    self.title = @"Parent Profile Settings";
    self.teen = [[SNTeenProfile alloc] init];
    SNTeenProfile *sp = [SNTeenProfile savedTeen];
    
    if (nil == sp) {
        self.teen.name = @"Jane Doe";
        self.teen.number = @"555-555-5555";
        self.teen.email = @"jane.doe@email.com";
        NSLog(@"[%@ Teen Profile]", self.teen.description);
    } else {
        self.teen.name = sp.name;
        self.teen.number = sp.number;
        self.teen.email = sp.email;
        NSLog(@"[%@ Saved Teen Profile]", self.teen.description);
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    cell.textFieldValue.delegate = self;
    cell.textFieldValue.tag = indexPath.row;
    
    // there should only be 3 elements
    switch (indexPath.row) {
        case 0:
            cell.imageView.image = [UIImage imageNamed:[self.thumbNails objectAtIndex:indexPath.row]];
            cell.textFieldValue.placeholder = self.teen.name;
            break;
        case 1:
            cell.imageView.image = [UIImage imageNamed:[self.thumbNails objectAtIndex:indexPath.row]];
            cell.textFieldValue.placeholder = self.teen.number;
            break;
        case 2:
            cell.imageView.image = [UIImage imageNamed:[self.thumbNails objectAtIndex:indexPath.row]];
            cell.textFieldValue.placeholder = self.teen.email;
            break;
        default:
            break;
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
        [self.teen save];
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
    
    
    switch (textField.tag) {
        case 0:{
            self.teen.name = textField.text;
            break;
        }
        case 1:{
            self.teen.number = textField.text;
            break;
        }
        case 2:{
            self.teen.email = textField.text;
            break;
        }
        default:
            break;
    }
    _selectedTextField = nil;
    NSLog(@"textFieldDidEndEditing");
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
