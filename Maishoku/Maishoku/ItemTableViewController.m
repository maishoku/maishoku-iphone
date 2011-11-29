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

@implementation ItemTableViewController
{
    NSMutableArray *categories; // [{'title': title, 'items': [item]}]
    UIActivityIndicatorView *spinner;
    NSInteger itemId;
    NSString *categoryName;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationItem setTitle:UIAppDelegate.restaurant.name];
    
    if (categories == NULL) {
        categories = [NSMutableArray arrayWithCapacity:16];
    } else {
        return;
    }
    
    // Show a spinner while we wait
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    struct CGSize size = [[UIScreen mainScreen] bounds].size;
    [spinner setCenter:CGPointMake(size.width/2.0, ((size.height)/2.0)-49)]; // tab bar is 49 pixels high
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    // Set up the Category object mapping
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[Category class]];
    [objectMapping mapKeyPath:@"name_japanese" toAttribute:@"nameJapanese"];
    [objectMapping mapKeyPath:@"name_english" toAttribute:@"nameEnglish"];
    [objectMapping mapKeyPath:@"available" toAttribute:@"available"];
    [objectMapping mapKeyPath:@"items" toAttribute:@"items"];
    [objectMapping mapKeyPath:@"id" toAttribute:@"id"];
    
    // Retrieve the list of categories for this restaurant from the server
    NSString *resourcePath = [NSString stringWithFormat:@"/restaurant/%d/categories", UIAppDelegate.restaurant.id];
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ItemViewController *itemViewController = (ItemViewController *)[segue destinationViewController];
    [itemViewController setItemId:itemId];
    [itemViewController setCategoryName:categoryName];
}

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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"¥%d", [[dict objectForKey:@"price"] intValue]];
    
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

- (IBAction)showCart:(id)sender
{
    UIViewController *cartViewController = [UIAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"CartNavigationViewController"];
    [self presentModalViewController:cartViewController animated:YES];
}

/*------------------------------------------------------------------------------------*/
/* RKObjectLoaderDelegate                                                             */
/*------------------------------------------------------------------------------------*/

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *keys = [NSArray arrayWithObjects:@"title", @"items", nil];
        Category *category = (Category *)obj;
        NSArray *items = [category.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"available == YES", nil]];
        NSString *name = UIAppDelegate.displayLanguage == english ? category.nameEnglish : category.nameJapanese;
        NSArray *objects = [NSArray arrayWithObjects:name, items, nil];
        if ([items count] != 0) {
            [categories addObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
        }
    }];
    [spinner stopAnimating];
    [self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Encountered an error: %@", error);
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    spinner = nil;
    categories = nil;
    categoryName = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
