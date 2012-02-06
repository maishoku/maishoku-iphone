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
    NSArray *positions;
    NSInteger totalPrice;
}

@synthesize restaurantLabel;
@synthesize priceLabel;
@synthesize amountRemainingLabel;
@synthesize itemsTable;
@synthesize checkoutButton;

- (void)reloadCart
{
    positions = [Cart allPositions];
    NSInteger price = 0;
    for (Position *position in positions) {
        price += [position.item.price intValue] * position.quantity;
        for (Option *option in position.options) {
            price += [option.priceDelta integerValue];
        }
        for (Topping *topping in position.toppings) {
            price += [topping.priceFixed integerValue];
        }
    }
    totalPrice = price;
    NSInteger amountRemaining = [UIAppDelegate.restaurant.minimumOrder integerValue] - totalPrice;
    if (amountRemaining > 0) {
        [amountRemainingLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Amount Remaining", nil), amountRemaining]];
        [checkoutButton setEnabled:NO];
    } else {
        [amountRemainingLabel setText:nil];
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
    [checkoutButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
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
            Position *position = [positions objectAtIndex:indexPath.row];
            [Cart removePosition:position];
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
    
    Position *position = [positions objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", position.item.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", position.quantity];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [positions count];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    positions = nil;
    [self setItemsTable:nil];
    [self setRestaurantLabel:nil];
    [self setPriceLabel:nil];
    [self setCheckoutButton:nil];
    [self setAmountRemainingLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
