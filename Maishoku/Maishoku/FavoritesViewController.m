//
//  FavoritesViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "Favorite.h"
#import "FavoritesViewController.h"
#import <RestKit/RestKit.h>

@implementation FavoritesViewController
{
    NSMutableArray *favorites;
}

@synthesize favoritesTable;
@synthesize spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Favorites", nil)];
    favorites = [NSMutableArray arrayWithCapacity:4];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [spinner startAnimating];
    
    // Set up the Favorite object mapping
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[Favorite class]];
    [objectMapping mapKeyPath:@"name" toAttribute:@"name"];
    [objectMapping mapKeyPath:@"order.restaurant.name_english" toAttribute:@"restaurantNameEnglish"];
    [objectMapping mapKeyPath:@"order.restaurant.name_japanese" toAttribute:@"restaurantNameJapanese"];
    [objectMapping mapKeyPath:@"order.items" toAttribute:@"items"];
    [objectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    
    // Retrieve the list of favorites from the server
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/user/favorites" objectMapping:objectMapping delegate:self];
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDelegate                                                                */
/*------------------------------------------------------------------------------------*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSUInteger row = indexPath.row;
    if (row != NSNotFound) {
        // get favorite
    }
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDataSource                                                              */
/*------------------------------------------------------------------------------------*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == favoritesTable) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [tableView beginUpdates];
            NSNumber *identifier = ((Favorite *)[favorites objectAtIndex:indexPath.row]).identifier;
            NSString *resourcePath = [NSString stringWithFormat:@"/favorites/%@", identifier];
            [[RKClient sharedClient] delete:resourcePath delegate:nil]; // Should 'always' succeed, so don't care about the response
            [favorites removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:YES];
            [tableView endUpdates];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoriteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Favorite *favorite = [favorites objectAtIndex:indexPath.row];
    cell.textLabel.text = favorite.name;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [favorites count];
}

/*------------------------------------------------------------------------------------*/
/* RKObjectLoaderDelegate                                                             */
/*------------------------------------------------------------------------------------*/

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    [favorites removeAllObjects];
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [favorites addObject:(Favorite *)obj];
    }];
    [spinner stopAnimating];
    [favoritesTable reloadData];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [spinner stopAnimating];
    [[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    favorites = nil;
    [self setFavoritesTable:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
