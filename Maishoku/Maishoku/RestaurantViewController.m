//
//  RestaurantViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/27/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "RestaurantViewController.h"

#define ADDRESS 0
#define PHONE_NUMBER 1
#define DELIVERY_TIME 2
#define MINIMUM_ORDER 3
#define CUISINES 4

@implementation RestaurantViewController

@synthesize seeItemsButton;
@synthesize navigationItem;
@synthesize restaurantInfoTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [seeItemsButton setTitle:NSLocalizedString(@"See Menu", nil) forState:UIControlStateNormal];
    [navigationItem setTitle:UIAppDelegate.restaurant.name];
}

- (IBAction)seeItems:(id)sender
{
    [self performSegueWithIdentifier:@"ItemsSegue" sender:nil];
}

- (IBAction)showCart:(id)sender
{
    UIViewController *cartViewController = [UIAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"CartNavigationViewController"];
    [self presentModalViewController:cartViewController animated:YES];
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDataSource                                                              */
/*------------------------------------------------------------------------------------*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RestaurantInfoCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section) {
        case ADDRESS:
            [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
            [cell.textLabel setText:UIAppDelegate.restaurant.address];
            [cell.detailTextLabel setText:NSLocalizedString(@"Address", nil)];
            break;
        case PHONE_NUMBER:
            [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
            [cell.textLabel setText:UIAppDelegate.restaurant.phoneOrder];
            [cell.detailTextLabel setText:NSLocalizedString(@"Phone Order", nil)];
            break;
        case DELIVERY_TIME:
            [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
            [cell.textLabel setText:UIAppDelegate.restaurant.deliveryTime];
            [cell.detailTextLabel setText:NSLocalizedString(@"Delivery Time", nil)];
            break;
        case MINIMUM_ORDER:
            [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
            [cell.textLabel setText:[NSString stringWithFormat:@"%@円", UIAppDelegate.restaurant.minimumOrder]];
            [cell.detailTextLabel setText:NSLocalizedString(@"Minimum Order", nil)];
            break;
        case CUISINES:
            [cell.textLabel setAdjustsFontSizeToFitWidth:NO];
            [cell.textLabel setLineBreakMode:UILineBreakModeTailTruncation];
            [cell.textLabel setText:UIAppDelegate.restaurant.commaSeparatedCuisines];
            [cell.detailTextLabel setText:NSLocalizedString(@"Cuisines", nil)];
            break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    [self setNavigationItem:nil];
    [self setSeeItemsButton:nil];
    [self setRestaurantInfoTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
