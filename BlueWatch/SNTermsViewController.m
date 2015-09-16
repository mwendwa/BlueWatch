//
//  SNMainTableViewController.m
//  BlueWatch
//
//  Created by Eugene Alute Mwendwa on 9/22/14.
//  Copyright (c) 2014 SafeNet Industries. All rights reserved.
//

#import "SNTermsViewController.h"
#import "SWRevealViewController.h"
#import "SNParentProfileViewController.h"
#import "SNSidebarViewController.h"

#define APP_TITLE @"BlueWatch Terms"
#define ACCEPT_TERMS @"acceptTerms"
#define DECLINE_TERMS @"declineTerms"

@interface SNTermsViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSDate *timeofDay;

@end

@implementation SNTermsViewController

@synthesize emergencyContactView;

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
    
    // Check if first run
    /*if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunchedOnce"]) {
     //first launch
     SNTermsViewController *termsViewController = [[SNTermsViewController alloc] init];
     [self presentViewController:termsViewController animated:YES completion:^{
     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunchedOnce"];
     [[NSUserDefaults standardUserDefaults] synchronize];
     }];
     }
     else
     {
     // app already launched
     NSLog(@"Not the first launch.");
     }*/
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
    tlabel.text = APP_TITLE;
    tlabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0];
    tlabel.textColor=[UIColor grayColor];
    tlabel.backgroundColor =[UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=tlabel;
    
    // emboss so that the label looks OK
    [tlabel setShadowColor:[UIColor darkGrayColor]];
    [tlabel setShadowOffset:CGSizeMake(0, -0.5)];
    self.navigationItem.titleView = tlabel;
    
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    //self.sidebarButton.target = self.revealViewController;
    //self.sidebarButton.action = @selector(revealToggle:);
    
    _menuItems = @[@"agreement0", @"agreement1", @"agreement2", @"agreement3", @"agreement4", @"agreement5", @"agreement6", @"agreement7", @"agreement8", @"agreement9",@"agreement10", @"agreement11", @"agreement12", @"agreement13"];
    
    NSLog(@"[%@ viewDidLoad]",self);

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
    NSLog(@"row: %li", (long)indexPath.row);
    
    NSString *cellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
   
    switch (indexPath.row) {
        
        case 0:
        {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            imgView.image = [UIImage imageNamed:@"57pt.png"];
            cell.imageView.image = imgView.image;
            cell.imageView.center = CGPointMake(cell.contentView.bounds.size.width/2,cell.contentView.bounds.size.height/2);
        }
            break;
        /*
        case 1:
        {
            cell.textLabel.text = @"";
        }
            break;
        */
        case 1:
        {
            cell.textLabel.text = @"BLUEWATCH END USER LICENSE AGREEMENT";
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.tag = 1;
            cell.userInteractionEnabled = NO;
            
            //tableView width - left border width - accessory indicator - right border width
            CGFloat width = tableView.frame.size.width - 15 - 30 - 15;
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:12.0];
            NSAttributedString *attributedText = [[NSAttributedString alloc]
                                                  initWithString:cell.textLabel.text
                                                  attributes:@{ NSFontAttributeName: font,
                                                                NSForegroundColorAttributeName: [UIColor grayColor],
                                                               }];
            
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
            CGSize size = rect.size;
            size.height = ceilf(size.height);
            size.width  = ceilf(size.width);
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"";
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"1. Thank you for purchasing BlueWatch. When you encounter a traffic stop by the police, it can be a stressful experience. This application is designed to assist in guiding you through the steps that will help you safely interact with law enforcement. Additionally, this application will make public the entire interaction in real time. Your designated point of contact will will receive a call and your GPS coordinates as the stop occurs. So what was once a local event occurring between the police and the citizen, with BlueWatch will now be a very public event. Finally, the entire interaction will be recorded for later use if needed.";
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.tag = 3;
            
            //tableView width - left border width - accessory indicator - right border width
            CGFloat width = tableView.frame.size.width - 15 - 30 - 15;
            UIColor *color = [UIColor blackColor];
            NSAttributedString *attributedText = [[NSAttributedString alloc]
                                                  initWithString:cell.textLabel.text
                                                  attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:12.0],
                                                                NSForegroundColorAttributeName: color,
                                                                }];
            
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
            CGSize size = rect.size;
            size.height = ceilf(size.height);
            size.width  = ceilf(size.width);
        }
            break;
        case 5:
        {
            cell.textLabel.text = @"2. YOUR USE OF THIS REAL TIME TRAFFIC STOP GUIDANCE APPLICATION IS AT YOUR SOLE RISK. LOCATION DATA MAY NOT BE ACCURATE.";
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.tag = 5;
            
            //tableView width - left border width - accessory indicator - right border width
            CGFloat width = tableView.frame.size.width - 15 - 30 - 15;
            UIFont *font = [UIFont systemFontOfSize:22.0f];
            //UIFont *font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:12.0f];
            NSAttributedString *attributedText = [[NSAttributedString alloc]
                                                  initWithString:cell.textLabel.text
                                                  attributes:@{ NSFontAttributeName: font,
                                                                NSForegroundColorAttributeName: [UIColor blueColor],
                                                                }];
            
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
            CGSize size = rect.size;
            size.height = ceilf(size.height);
            size.width  = ceilf(size.width);
        }
            break;
        case 6:
        {
            cell.textLabel.text = @"3. Getting Started: Please go to \"Emergency Contact\" and fill in your designated point of contact who will be called during a traffic stop. Remember, that person will also receive your GPS coordinates as well. We will need you to fill out your information in \"User Profile\" as well.";
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.tag = 6;
            
            //tableView width - left border width - accessory indicator - right border width
            CGFloat width = tableView.frame.size.width - 15 - 30 - 15;
            //UIFont *font = [UIFont systemFontOfSize:22.0f];
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:12.0f];
            UIColor *color = [UIColor blackColor];
            NSAttributedString *attributedText = [[NSAttributedString alloc]
                                                  initWithString:cell.textLabel.text
                                                  attributes:@{ NSFontAttributeName: font,
                                                                NSForegroundColorAttributeName: color,
                                                                }];
            
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
            CGSize size = rect.size;
            size.height = ceilf(size.height);
            size.width  = ceilf(size.width);
        }
            break;
        case 7:
        {
            cell.textLabel.text = @"4. Once you have done this, please click on \"Accept Terms & Activate\" and you are ready.";
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.tag = 7;
            
            //tableView width - left border width - accessory indicator - right border width
            CGFloat width = tableView.frame.size.width - 15 - 30 - 15;
            //UIFont *font = [UIFont systemFontOfSize:22.0f];
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:12.0f];
            UIColor *color = [UIColor blackColor];
            NSAttributedString *attributedText = [[NSAttributedString alloc]
                                                  initWithString:cell.textLabel.text
                                                  attributes:@{ NSFontAttributeName: font,
                                                                NSForegroundColorAttributeName: color,
                                                                }];
            
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
            CGSize size = rect.size;
            size.height = ceilf(size.height);
            size.width  = ceilf(size.width);
        }
            break;
        case 8:
        {
            cell.textLabel.text = @"5. Always pay your full attention to the road and abide with all transportation laws and regulations and most important of all law enforcement commands.";
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.tag = 8;
            
            //tableView width - left border width - accessory indicator - right border width
            CGFloat width = tableView.frame.size.width - 15 - 30 - 15;
            //UIFont *font = [UIFont systemFontOfSize:22.0f];
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:12.0f];
            UIColor *color = [UIColor blackColor];
            NSAttributedString *attributedText = [[NSAttributedString alloc]
                                                  initWithString:cell.textLabel.text
                                                  attributes:@{ NSFontAttributeName: font,
                                                                NSForegroundColorAttributeName: color,
                                                                }];
            
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
            CGSize size = rect.size;
            size.height = ceilf(size.height);
            size.width  = ceilf(size.width);
        }
            break;
        case 12:
        {
            UIButton *button1=[UIButton  buttonWithType:UIButtonTypeRoundedRect];
            button1.tag=indexPath.row;
            [button1 setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted & UIControlStateNormal & UIControlStateSelected];
            [button1 addTarget:self
                        action:@selector(declineMethod:) forControlEvents:UIControlEventTouchDown];
            [button1 setTitle:@"Decline" forState:UIControlStateNormal & UIControlStateHighlighted & UIControlStateSelected];
            [button1.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0]];
            [button1 setBackgroundColor:[UIColor clearColor]];
            button1.frame = CGRectMake(90.0, 7.0, 90.0, 40.0);
            button1.layer.borderWidth = 0.5f;
            button1.layer.borderColor = [UIColor grayColor].CGColor;
            [button1.titleLabel setShadowColor:[UIColor darkGrayColor]];
            [button1.titleLabel setShadowOffset:CGSizeMake(0, -0.5)];
            button1.titleLabel.adjustsFontSizeToFitWidth = YES;
            button1.titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:button1];
            
            UIButton *button2=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            button2.tag=indexPath.row;
            [button2 setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted & UIControlStateNormal & UIControlStateSelected];
            [button2 addTarget:self
                       action:@selector(acceptMethod:) forControlEvents:UIControlEventTouchDown];
            [button2 setTitle:@"Accept" forState:UIControlStateNormal];
            [button2.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0]];
            [button2 setBackgroundColor:[UIColor clearColor]];
            button2.frame = CGRectMake(225, 7.0, 90.0, 40.0);
            button2.layer.borderWidth = 0.5f;
            button2.layer.borderColor = [UIColor grayColor].CGColor;
            [button2.titleLabel setShadowColor:[UIColor darkGrayColor]];
            [button2.titleLabel setShadowOffset:CGSizeMake(0, -0.5)];
            button2.titleLabel.adjustsFontSizeToFitWidth = YES;
            button2.titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:button2];
            
            return cell;
        }
            break;

        default:
            break;
    }
    
    return cell;
}

-(void)acceptMethod:(UIButton *)sender
{
    NSLog(@"Clicked accept button %ld",(long)sender.tag);
    [self performSegueWithIdentifier:ACCEPT_TERMS sender: sender];
}

-(void)declineMethod:(UIButton *)sender
{
    NSLog(@"Clicked decline button %ld",(long)sender.tag);
    [self performSegueWithIdentifier:DECLINE_TERMS sender: sender];
}

- (IBAction)unwindToViewControllerNameHere:(UIStoryboardSegue *)segue {
    //nothing goes here
}

- (void)prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    if ([segue.identifier isEqualToString:ACCEPT_TERMS]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        [self.navigationController  presentViewController:navController animated:YES completion:nil];
        
        //UIViewController *destController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ParentViewController"];
        //UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:destController];
        //[self.navigationController presentViewController:navigation animated:YES completion:nil];
        
    }
    
    if ([segue.identifier isEqualToString:DECLINE_TERMS]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        SWRevealViewController *initView =  (SWRevealViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [initView setModalPresentationStyle:UIModalPresentationFullScreen];
        [self.navigationController presentViewController:initView animated:NO completion:nil];
    }
    
}

@end

