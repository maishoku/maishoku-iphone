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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    // It would be great to get the width from cell.textLabel.frame.size.width, but tableView:heightForRowAtIndexPath:
    // is called before the UITableViewCell is rendered, so the width is not yet set.
    CGFloat width = 280.0;
    CGFloat singleLineSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font].height;
    CGFloat multiLineSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)].height;
    height += multiLineSize - singleLineSize;
    singleLineSize = [cell.detailTextLabel.text sizeWithFont:cell.detailTextLabel.font].height;
    multiLineSize = [cell.detailTextLabel.text sizeWithFont:cell.detailTextLabel.font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)].height;
    height += multiLineSize - singleLineSize;
    return height;
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
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%+d円)", topping.name, [topping.priceFixed integerValue]];
    [cell.textLabel sizeToFit];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = topping.description;
    [cell.detailTextLabel sizeToFit];
    
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
