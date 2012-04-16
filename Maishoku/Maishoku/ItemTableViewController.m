//
//  ItemTableViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Category.h"
#import "Item.h"
#import "ItemViewController.h"
#import "ItemTableViewController.h"
#import "TableViewCellImageConnectionDelegate.h"

@implementation ItemTableViewController
{
    NSMutableArray *categories; // [{'title': title, 'items': [item]}]
    UIActivityIndicatorView *spinner;
    NSInteger itemId;
    NSString *categoryName;
    UIImage *blank;
    NSMutableSet *urls;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Menu", nil)];
    blank = [UIImage imageNamed:@"blank40x40.png"];
    urls = [NSMutableSet set];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (categories == NULL) {
        categories = [NSMutableArray array];
    } else {
        return;
    }
    
    // Show a spinner while we wait
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    struct CGSize size = [[UIScreen mainScreen] bounds].size;
    [spinner setCenter:CGPointMake(size.width/2.0, size.height/2.0)];
    [self.navigationController.view addSubview:spinner];
    [spinner startAnimating];
    
    // Set up the Category object mapping
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[Category class]];
    [objectMapping mapKeyPath:@"name_japanese" toAttribute:@"nameJapanese"];
    [objectMapping mapKeyPath:@"name_english" toAttribute:@"nameEnglish"];
    [objectMapping mapKeyPath:@"available" toAttribute:@"available"];
    [objectMapping mapKeyPath:@"items" toAttribute:@"items"];
    [objectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    
    // Retrieve the list of categories for this restaurant from the server
    NSString *resourcePath = [NSString stringWithFormat:@"/restaurants/%@/categories", UIAppDelegate.restaurant.identifier];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ItemViewController *itemViewController = (ItemViewController *)[segue destinationViewController];
    [itemViewController setItemId:itemId];
    [itemViewController setCategoryName:categoryName];
}

- (IBAction)showCart:(id)sender
{
    UIViewController *cartViewController = [UIAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"CartNavigationViewController"];
    [self presentModalViewController:cartViewController animated:YES];
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
    
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    if (section != NSNotFound && row != NSNotFound) {
        NSDictionary *dict = [categories objectAtIndex:section];
        NSDictionary *items = [[dict objectForKey:@"items"] objectAtIndex:row];
        itemId = [[items objectForKey:@"id"] intValue];
        categoryName = (NSString *)[dict objectForKey:@"title"];
        [self performSegueWithIdentifier:@"ItemSegue" sender:nil];
    }
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDataSource                                                              */
/*------------------------------------------------------------------------------------*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dict = [[[categories objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
    NSString *name = UIAppDelegate.displayLanguage == english ? @"name_english" : @"name_japanese";
    cell.textLabel.text = [dict objectForKey:name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"¥%@", [dict objectForKey:@"price"]];
    
    NSString *url = [dict objectForKey:@"thumbnail_image_url"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSCachedURLResponse *response = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    
    if (response.data == nil && ![urls containsObject:url]) {
        [urls addObject:url];
        cell.imageView.image = blank;
        TableViewCellImageConnectionDelegate *delegate = [[TableViewCellImageConnectionDelegate alloc] init];
        delegate.tableViewCell = cell;
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
        if (connection == nil) {}; // get rid of "expression result unused" warning
    } else {
        UIImage *image = [[UIImage alloc] initWithData:response.data];
        if (image == nil) {
            cell.imageView.image = blank;
        } else {
            cell.imageView.image = image;
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [categories count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[categories objectAtIndex:section] objectForKey:@"title"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[categories objectAtIndex:section] objectForKey:@"items"] count];
}

/*------------------------------------------------------------------------------------*/
/* RKObjectLoaderDelegate                                                             */
/*------------------------------------------------------------------------------------*/

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    for (Category *category in objects) {
        NSArray *keys = [NSArray arrayWithObjects:@"title", @"items", nil];
        NSArray *items = [category.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"available == YES", nil]];
        NSArray *objects = [NSArray arrayWithObjects:category.name, items, nil];
        if ([items count] != 0) {
            [categories addObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
        }
    };
    [spinner stopAnimating];
    [self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [spinner stopAnimating];
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed To Load Items", nil) message:NSLocalizedString(@"Load Screen Again", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    urls = nil;
    blank = nil;
    spinner = nil;
    categories = nil;
    categoryName = nil;
    [super viewDidUnload];
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
