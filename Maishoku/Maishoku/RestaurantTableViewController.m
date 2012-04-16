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
#import "RestaurantHours.h"
#import "DeliveryDistance.h"
#import "RestaurantTableViewController.h"
#import "TableViewCellImageConnectionDelegate.h"

@implementation RestaurantTableViewController
{
    NSMutableArray *restaurants;
    UIActivityIndicatorView *spinner;
    NSMutableSet *urls;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Restaurants", nil)];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    restaurants = [NSMutableArray array];
    urls = [NSMutableSet set];
}

- (void)loadRestaurants
{
    // Show a spinner while we wait
    struct CGSize size = [[UIScreen mainScreen] bounds].size;
    [spinner setCenter:CGPointMake(size.width/2.0, size.height/2.0)];
    [self.navigationController.view addSubview:spinner];
    [spinner startAnimating];
    
    // Set up the object mappings
    RKObjectMapping *restaurantHoursObjectMapping = [RKObjectMapping mappingForClass:[RestaurantHours class]];
    [restaurantHoursObjectMapping mapKeyPath:@"day_name" toAttribute:@"dayName"];
    [restaurantHoursObjectMapping mapKeyPath:@"open_time" toAttribute:@"openTime"];
    [restaurantHoursObjectMapping mapKeyPath:@"close_time" toAttribute:@"closeTime"];
    
    RKObjectMapping *deliveryDistanceObjectMapping = [RKObjectMapping mappingForClass:[DeliveryDistance class]];
    [deliveryDistanceObjectMapping mapKeyPath:@"lower_bound" toAttribute:@"lowerBound"];
    [deliveryDistanceObjectMapping mapKeyPath:@"upper_bound" toAttribute:@"upperBound"];
    [deliveryDistanceObjectMapping mapKeyPath:@"minimum_delivery" toAttribute:@"minimumDelivery"];
    
    RKObjectMapping *restaurantObjectMapping = [RKObjectMapping mappingForClass:[Restaurant class]];
    NSString *deliveryTime;
    if (UIAppDelegate.displayLanguage == english) {
        deliveryTime = @"delivery_time.value_english";
    } else {
        deliveryTime = @"delivery_time.value_japanese";
    }
    [restaurantObjectMapping mapKeyPath:deliveryTime toAttribute:@"deliveryTime"];
    [restaurantObjectMapping mapKeyPath:@"dirlogo_image_url" toAttribute:@"dirlogoImageURL"];
    [restaurantObjectMapping mapKeyPath:@"mainlogo_image_url" toAttribute:@"mainlogoImageURL"];
    [restaurantObjectMapping mapKeyPath:@"description_japanese" toAttribute:@"descriptionJapanese"];
    [restaurantObjectMapping mapKeyPath:@"description_english" toAttribute:@"descriptionEnglish"];
    [restaurantObjectMapping mapKeyPath:@"name_japanese" toAttribute:@"nameJapanese"];
    [restaurantObjectMapping mapKeyPath:@"name_english" toAttribute:@"nameEnglish"];
    [restaurantObjectMapping mapKeyPath:@"phone_order" toAttribute:@"phoneOrder"];
    [restaurantObjectMapping mapKeyPath:@"minimum_order" toAttribute:@"minimumOrder"];
    [restaurantObjectMapping mapKeyPath:@"distance" toAttribute:@"distance"];
    [restaurantObjectMapping mapKeyPath:@"cuisines" toAttribute:@"cuisines"];
    [restaurantObjectMapping mapKeyPath:@"address" toAttribute:@"address"];
    [restaurantObjectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    [restaurantObjectMapping mapKeyPath:@"hours" toRelationship:@"hours" withMapping:restaurantHoursObjectMapping];
    [restaurantObjectMapping mapKeyPath:@"delivery_distances" toRelationship:@"deliveryDistances" withMapping:deliveryDistanceObjectMapping];
    
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
    [manager loadObjectsAtResourcePath:resourcePath objectMapping:restaurantObjectMapping delegate:self];
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

- (void)dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDelegate                                                                */
/*------------------------------------------------------------------------------------*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSUInteger row = indexPath.row;
    if (row != NSNotFound) {
        Restaurant *restaurant = [restaurants objectAtIndex:row];
        if (restaurant != UIAppDelegate.restaurant) {
            [Cart clear];
            UIAppDelegate.restaurant = restaurant;
        }
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
    
    NSString *url = restaurant.dirlogoImageURL;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSCachedURLResponse *response = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    
    if (response.data == nil && ![urls containsObject:url]) {
        [urls addObject:url];
        cell.imageView.image = UIAppDelegate.blank60x40;
        TableViewCellImageConnectionDelegate *delegate = [[TableViewCellImageConnectionDelegate alloc] init];
        delegate.tableViewCell = cell;
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
        if (connection == nil) {}; // get rid of "expression result unused" warning
    } else {
        UIImage *image = [[UIImage alloc] initWithData:response.data];
        if (image == nil) {
            cell.imageView.image = UIAppDelegate.blank60x40;
        } else {
            cell.imageView.image = image;
        }
    }
    
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
    for (Restaurant *restaurant in objects) {
        [restaurants addObject:restaurant];
    };
    [UIAppDelegate setRestaurantsLoaded:YES];
    [spinner stopAnimating];
    [self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [spinner stopAnimating];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed To Load Restaurants", nil) message:NSLocalizedString(@"Load Screen Again", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    restaurants = nil;
    spinner = nil;
    urls = nil;
}

- (void)didReceiveMemoryWarning
{
    [urls removeAllObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
