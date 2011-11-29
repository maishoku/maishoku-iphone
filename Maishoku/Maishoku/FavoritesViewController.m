//
//  FavoritesViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "FavoritesViewController.h"
#import <RestKit/RestKit.h>

@implementation FavoritesViewController

@synthesize itemsTable;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Favorites", nil)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    if (tableView == itemsTable) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [tableView beginUpdates];
            // delete favorite
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
    
//    Address *address = [addresses objectAtIndex:indexPath.row];
//    cell.textLabel.text = address.address;
//    cell.textLabel.textColor = [UIColor whiteColor];
//    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
//    return [favorites count];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    [self setItemsTable:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
