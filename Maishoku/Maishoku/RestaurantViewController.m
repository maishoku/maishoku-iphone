//
//  RestaurantViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/27/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "RestaurantViewController.h"

@implementation RestaurantViewController

@synthesize addressLabel;
@synthesize phoneNumberLabel;
@synthesize deliveryTimeLabel;
@synthesize minimumOrderLabel;
@synthesize cuisinesLabel;
@synthesize seeItemsButton;
@synthesize navigationItem;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [phoneNumberLabel setText:UIAppDelegate.restaurant.phoneContact];
    [addressLabel setText:UIAppDelegate.restaurant.address];
    [deliveryTimeLabel setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Delivery Time", nil), UIAppDelegate.restaurant.deliveryTime]];
    [minimumOrderLabel setText:[NSString stringWithFormat:@"%@: ¥%i", NSLocalizedString(@"Minimum Order", nil), UIAppDelegate.restaurant.minimumOrder]];
    [cuisinesLabel setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Cuisines", nil), UIAppDelegate.restaurant.commaSeparatedCuisines]];
    [seeItemsButton setTitle:NSLocalizedString(@"See Items", nil) forState:UIControlStateNormal];
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

- (void)viewDidUnload
{
    [self setNavigationItem:nil];
    [self setDeliveryTimeLabel:nil];
    [self setMinimumOrderLabel:nil];
    [self setAddressLabel:nil];
    [self setPhoneNumberLabel:nil];
    [self setCuisinesLabel:nil];
    [self setSeeItemsButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
