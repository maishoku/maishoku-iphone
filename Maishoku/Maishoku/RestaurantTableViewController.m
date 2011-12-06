//
//  RestaurantTableViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "Cart.h"
#import "AppDelegate.h"
#import "Restaurant.h"
#import "RestaurantTableViewController.h"

@implementation RestaurantTableViewController
{
    NSMutableArray *restaurants;
    UIActivityIndicatorView *spinner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Restaurants", nil)];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    restaurants = [NSMutableArray arrayWithCapacity:4];
}

- (void)loadRestaurants
{
    // Show a spinner while we wait
    struct CGSize size = [[UIScreen mainScreen] bounds].size;
    [spinner setCenter:CGPointMake(size.width/2.0, ((size.height)/2.0)-49)]; // tab bar is 49 pixels high
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    // Set up the Restaurant object mapping
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[Restaurant class]];
    NSString *deliveryTime;
    if (UIAppDelegate.displayLanguage == english) {
        deliveryTime = @"delivery_time.value_english";
    } else {
        deliveryTime = @"delivery_time.value_japanese";
    }
    [objectMapping mapKeyPath:deliveryTime toAttribute:@"deliveryTime"];
    [objectMapping mapKeyPath:@"name_japanese" toAttribute:@"nameJapanese"];
    [objectMapping mapKeyPath:@"name_english" toAttribute:@"nameEnglish"];
    [objectMapping mapKeyPath:@"phone_contact" toAttribute:@"phoneContact"];
    [objectMapping mapKeyPath:@"minimum_order" toAttribute:@"minimumOrder"];
    [objectMapping mapKeyPath:@"cuisines" toAttribute:@"cuisines"];
    [objectMapping mapKeyPath:@"address" toAttribute:@"address"];
    [objectMapping mapKeyPath:@"hours" toAttribute:@"hours"];
    [objectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    
    // Format the GET query params
    NSArray *keys = [NSArray arrayWithObjects:@"lat", @"lon", nil];
    NSNumber *lat = [NSNumber numberWithFloat:UIAppDelegate.address.lat];
    NSNumber *lon = [NSNumber numberWithFloat:UIAppDelegate.address.lon];
    NSArray *values = [NSArray arrayWithObjects:lat, lon, nil];
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSString *baseURL = [[RKClient sharedClient] baseURL];
    
    NSString *resourcePath;
    if (UIAppDelegate.orderMethod == delivery) {
        resourcePath = @"/restaurants/search/delivery";
    } else {
        resourcePath = @"/restaurants/search/pickup";
    }
    
    // Retrieve the list of restaurants from the server
    RKURL *url = [RKURL URLWithBaseURLString:baseURL resourcePath:resourcePath queryParams:queryParams];
    resourcePath = [url.absoluteString substringFromIndex:[baseURL length]];
    RKObjectManager *manager = [RKObjectManager sharedManager];
    [manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([UIAppDelegate restaurantsLoaded]) {
        return;
    } else {
        [self loadRestaurants];
    }
}

- (IBAction)refresh:(id)sender
{
    [self loadRestaurants];
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDelegate                                                                */
/*------------------------------------------------------------------------------------*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSUInteger row = indexPath.row;
    if (row != NSNotFound) {
        [Cart clear];
        UIAppDelegate.restaurant = [restaurants objectAtIndex:row];
        [self performSegueWithIdentifier:@"RestaurantViewSegue" sender:nil];
    }
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDataSource                                                              */
/*------------------------------------------------------------------------------------*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RestaurantCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Restaurant *restaurant = [restaurants objectAtIndex:indexPath.row];
    cell.textLabel.text = restaurant.name;
    cell.detailTextLabel.text = restaurant.commaSeparatedCuisines;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [restaurants count];
}

/*------------------------------------------------------------------------------------*/
/* RKObjectLoaderDelegate                                                             */
/*------------------------------------------------------------------------------------*/

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    [restaurants removeAllObjects];
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [restaurants addObject:(Restaurant *)obj];
    }];
    [UIAppDelegate setRestaurantsLoaded:YES];
    [spinner stopAnimating];
    [self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    restaurants = nil;
    spinner = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
