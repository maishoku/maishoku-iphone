//
//  CartViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/23/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Cart.h"
#import "CartViewController.h"
#import "Favorite.h"

@implementation CartViewController
{
    NSArray *items;
    NSInteger totalPrice;
}

@synthesize restaurantLabel;
@synthesize priceLabel;
@synthesize itemsTable;
@synthesize checkoutButton;

- (void)reloadCart
{
    items = [Cart allItems];
    __block NSInteger price = 0;
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Item *item = (Item *)obj;
        price += [item.price intValue] * [Cart quantityForItem:item];
    }];
    totalPrice = price;
    if (totalPrice == 0) {
        [checkoutButton setEnabled:NO];
    } else {
        [checkoutButton setEnabled:YES];
    }
    [restaurantLabel setText:[NSString stringWithFormat:@"%@", UIAppDelegate.restaurant.name]];
    [priceLabel setText:[NSString stringWithFormat:@"%@: ¥%d", NSLocalizedString(@"Total Price", nil), totalPrice]];
    [itemsTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTintColor:MAISHOKU_RED];
    [self.navigationItem setTitle:NSLocalizedString(@"Cart", nil)];
    [checkoutButton setTitle:NSLocalizedString(@"Checkout", nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadCart];
}

- (IBAction)checkout:(id)sender
{
    [self performSegueWithIdentifier:@"CheckoutSegue" sender:nil];
}

- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDataSource                                                              */
/*------------------------------------------------------------------------------------*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == itemsTable) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            Item *item = (Item *)[items objectAtIndex:indexPath.row];
            [Cart removeFromCart:item];
            [self reloadCart];
            [tableView reloadData];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Item *item = (Item *)[items objectAtIndex:indexPath.row];
    NSInteger quantity = [Cart quantityForItem:item];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", item.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", quantity];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    items = nil;
    [self setItemsTable:nil];
    [self setRestaurantLabel:nil];
    [self setPriceLabel:nil];
    [self setCheckoutButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
