//
//  RestaurantViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/27/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "RestaurantViewController.h"

#define TOP 0
#define BOTTOM 1

#define ADDRESS 0
#define PHONE_NUMBER 1
#define HOURS 2
#define DELIVERY_TIME 0
#define MINIMUM_ORDER 1

@implementation RestaurantViewController
{
    NSMutableData *imageData;
}

@synthesize seeItemsButton;
@synthesize navigationItem;
@synthesize restaurantInfoTableView;
@synthesize imageView;
@synthesize restaurantNameLabel;
@synthesize cuisinesLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [seeItemsButton setTitle:NSLocalizedString(@"See Menu", nil) forState:UIControlStateNormal];
    [restaurantNameLabel setText:UIAppDelegate.restaurant.name];
    [cuisinesLabel setText:UIAppDelegate.restaurant.commaSeparatedCuisines];
    imageData = [NSMutableData data];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:UIAppDelegate.restaurant.mainlogoImageURL]];
    NSCachedURLResponse *response = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    
    if (response.data == nil) {
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (connection == nil) {}; // get rid of "expression result unused" warning
    } else {
        UIImage *image = [[UIImage alloc] initWithData:response.data];
        if (image != nil) {
            imageView.image = image;
        }
    }
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
/* NSURLConnectionDelegate                                                            */
/*------------------------------------------------------------------------------------*/

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [imageData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    imageData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    if (image != nil) {
        imageView.image = image;
    }
    imageData = nil;
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
        case TOP:
            switch (indexPath.row) {
                case ADDRESS:
                    [cell.textLabel setText:UIAppDelegate.restaurant.address];
                    [cell.detailTextLabel setText:NSLocalizedString(@"Address", nil)];
                    break;
                case PHONE_NUMBER:
                    [cell.textLabel setText:UIAppDelegate.restaurant.phoneOrder];
                    [cell.detailTextLabel setText:NSLocalizedString(@"Phone Order", nil)];
                    break;
                case HOURS:
                    [cell.textLabel setText:UIAppDelegate.restaurant.todaysHours];
                    [cell.detailTextLabel setText:NSLocalizedString(@"Todays Hours", nil)];
                    break;
            }
            break;
        case BOTTOM:
            switch (indexPath.row) {
                case DELIVERY_TIME:
                    [cell.textLabel setText:UIAppDelegate.restaurant.deliveryTime];
                    [cell.detailTextLabel setText:NSLocalizedString(@"Delivery Time", nil)];
                    break;
                case MINIMUM_ORDER:
                    [cell.textLabel setText:[NSString stringWithFormat:@"¥%@", UIAppDelegate.restaurant.minimumDelivery]];
                    [cell.detailTextLabel setText:NSLocalizedString(@"Minimum Delivery", nil)];
                    break;
            }
            break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case TOP: return 3;
        case BOTTOM: return 2;
    }
    return 0;
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    imageData = nil;
    [self setNavigationItem:nil];
    [self setSeeItemsButton:nil];
    [self setRestaurantInfoTableView:nil];
    [self setImageView:nil];
    [self setRestaurantNameLabel:nil];
    [self setCuisinesLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
