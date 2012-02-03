//
//  ToppingsViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 2/1/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Topping.h"
#import "ToppingsViewController.h"

@implementation ToppingsViewController

@synthesize item;
@synthesize position;
@synthesize label;
@synthesize toppingsTableView;
@synthesize navigationBar;
@synthesize button;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [button setTintColor:MAISHOKU_RED];
    [navigationBar setTintColor:MAISHOKU_RED];
    [label setText:NSLocalizedString(@"Choose Toppings", nil)];
}

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDelegate                                                                */
/*------------------------------------------------------------------------------------*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Topping *topping = [item.toppings objectAtIndex:indexPath.row];
    if (![position.toppings containsObject:topping]) {
        [position.toppings addObject:topping];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Topping *topping = [item.toppings objectAtIndex:indexPath.row];
    if ([position.toppings containsObject:topping]) {
        [position.toppings removeObject:topping];
    }
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDataSource                                                              */
/*------------------------------------------------------------------------------------*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ToppingCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Topping *topping = [item.toppings objectAtIndex:indexPath.row];
    cell.textLabel.text = topping.name;
    cell.detailTextLabel.text = topping.description;
    
    if ([position.toppings containsObject:topping]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [item.toppings count];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    [self setItem:nil];
    [self setPosition:nil];
    [self setLabel:nil];
    [self setToppingsTableView:nil];
    [self setNavigationBar:nil];
    [self setButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
