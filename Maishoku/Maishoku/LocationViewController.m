//
//  LocationViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/31/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "Address.h"
#import "AppDelegate.h"
#import "LocationViewController.h"
#import "NewAddressViewController.h"
#import <RestKit/RestKit.h>

@implementation LocationViewController
{
    NSMutableArray *addresses;
    CLLocationManager *locationManager;
    UIAlertView *alertView;
}

@synthesize logoutButton;
@synthesize addressLabel;
@synthesize addressView;
@synthesize segmentedControl;
@synthesize addNewAddressButton;
@synthesize locateButton;
@synthesize viewPresented;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self.tabBarController viewControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *viewController = (UIViewController *)obj;
        switch (viewController.tabBarItem.tag) {
            case 0:
                [viewController.tabBarItem setTitle:NSLocalizedString(@"Restaurants", nil)];
                break;
            case 1:
                [viewController.tabBarItem setTitle:NSLocalizedString(@"Favorites", nil)];
                break;
            case 2:
                [viewController.tabBarItem setTitle:NSLocalizedString(@"Groups", nil)];
                break;
        }
    }];
    
    [logoutButton setTitle:NSLocalizedString(@"Logout", nil)];
    [addressLabel setText:NSLocalizedString(@"Select Address", nil)];
    [segmentedControl setTitle:NSLocalizedString(@"Delivery", nil) forSegmentAtIndex:0];
    [segmentedControl setTitle:NSLocalizedString(@"Pickup", nil) forSegmentAtIndex:1];
    [addNewAddressButton setTitle:NSLocalizedString(@"Add New Address", nil) forState:UIControlStateNormal];
    
    alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Getting Location", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil, nil];
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    [UIAppDelegate setAddressesLoaded:NO];
    addresses = [NSMutableArray arrayWithCapacity:5];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self valueChanged:nil];
    
    [UIAppDelegate setRestaurantsLoaded:NO];
    
    if ([UIAppDelegate addressesLoaded]) {
        return;
    }
    
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[Address class]];
    [objectMapping mapKeyPath:@"address" toAttribute:@"address"];
    [objectMapping mapKeyPath:@"first_date" toAttribute:@"firstDate"];
    [objectMapping mapKeyPath:@"last_date" toAttribute:@"lastDate"];
    [objectMapping mapKeyPath:@"frequency" toAttribute:@"frequency"];
    [objectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    [objectMapping mapKeyPath:@"lat" toAttribute:@"lat"];
    [objectMapping mapKeyPath:@"lon" toAttribute:@"lon"];
    
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/user/addresses" objectMapping:objectMapping delegate:self];
}

- (IBAction)addAddress:(id)sender
{
    UIViewController *newAddressViewController = [UIAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"NewAddressViewController"];
    [self presentModalViewController:newAddressViewController animated:YES];
}

- (IBAction)logout:(id)sender
{
    [UIAppDelegate.keychain resetKeychainItem];
    [self performSegueWithIdentifier:@"LogoutSegue" sender:nil];
}

- (IBAction)valueChanged:(id)sender
{
    if ([segmentedControl selectedSegmentIndex] == 0) {
        UIAppDelegate.orderMethod = delivery;
        [locateButton setEnabled:NO];
    } else {
        UIAppDelegate.orderMethod = pickup;
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status != kCLAuthorizationStatusDenied && status != kCLAuthorizationStatusRestricted) {
            [locateButton setEnabled:YES];
        }
    }
}

- (IBAction)locate:(id)sender
{
    [self setViewPresented:NO];
    [locateButton setEnabled:NO];
    [alertView show];
    [locationManager startUpdatingLocation];
}

/*------------------------------------------------------------------------------------*/
/* UIAlertViewDelegate                                                                */
/*------------------------------------------------------------------------------------*/

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    [self setViewPresented:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"RestaurantTableViewSegue" sender:nil];
    }
}

- (void)stopUpdatingLocation
{
    [locationManager stopUpdatingLocation];
    [locateButton setEnabled:YES];
}

/*------------------------------------------------------------------------------------*/
/* CLLocationManagerDelegate                                                          */
/*------------------------------------------------------------------------------------*/

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (![self viewPresented]) {
        return;
    }
    [self stopUpdatingLocation];
    Address *address = [[Address alloc] init];
    [address setLat:newLocation.coordinate.latitude];
    [address setLon:newLocation.coordinate.longitude];
    [address setIdentifier:[NSNumber numberWithInt:1]];
    [UIAppDelegate setAddress:address];
    [alertView dismissWithClickedButtonIndex:1 animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    switch (error.code) {
        case kCLErrorLocationUnknown:
            // simply ignore the error and wait for a new event
            break;
        case kCLErrorDenied:
            // stop the location service
            [self stopUpdatingLocation];
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            break;
        default:
            [self stopUpdatingLocation];
            [alertView setTitle:nil];
            [alertView setMessage:NSLocalizedString(@"Locating Failed", nil)];
            break;
    }
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDelegate                                                                */
/*------------------------------------------------------------------------------------*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSUInteger row = indexPath.row;
    if (row != NSNotFound) {
        Address *address = [addresses objectAtIndex:indexPath.row];
        UIAppDelegate.address = address;
        [self performSegueWithIdentifier:@"RestaurantTableViewSegue" sender:nil];
    }
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDataSource                                                              */
/*------------------------------------------------------------------------------------*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == addressView && editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        NSNumber *identifier = ((Address *)[addresses objectAtIndex:indexPath.row]).identifier;
        NSString *resourcePath = [NSString stringWithFormat:@"/addresses/%@", identifier];
        [[RKClient sharedClient] delete:resourcePath delegate:nil]; // Should 'always' succeed, so don't care about the response
        [addresses removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:YES];
        [tableView endUpdates];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddressCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Address *address = [addresses objectAtIndex:indexPath.row];
    cell.textLabel.text = address.address;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [addresses count];
}

/*------------------------------------------------------------------------------------*/
/* RKObjectLoaderDelegate                                                             */
/*------------------------------------------------------------------------------------*/

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    [addresses removeAllObjects];
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [addresses addObject:(Address *)obj];
    }];
    [UIAppDelegate setAddressesLoaded:YES];
    [self.addressView reloadData];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:nil message:[[objectLoader response] bodyAsString] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    addresses = nil;
    locationManager = nil;
    alertView = nil;
    [self setAddressView:nil];
    [self setSegmentedControl:nil];
    [self setAddressLabel:nil];
    [self setLogoutButton:nil];
    [self setAddNewAddressButton:nil];
    [self setLocateButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
