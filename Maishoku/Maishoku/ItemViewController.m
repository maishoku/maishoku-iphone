//
//  ItemViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/21/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Cart.h"
#import "Item.h"
#import "Option.h"
#import "OptionSet.h"
#import "Topping.h"
#import "Position.h"
#import "ItemViewController.h"
#import "ToppingsViewController.h"
#import <RestKit/RestKit.h>

@implementation ItemViewController
{
    Item *item;
    Position *position;
    NSInteger index;
}

@synthesize nameLabel;
@synthesize priceLabel;
@synthesize categoryLabel;
@synthesize quantityLabel;
@synthesize selectedQuantityLabel;
@synthesize addToCartButton;
@synthesize quantityButton;
@synthesize itemId;
@synthesize categoryName;
@synthesize currentlyInCartLabel;
@synthesize spinner;
@synthesize extrasTableView;
@synthesize slider;
@synthesize extrasPickerView;

- (void)reloadLabel
{
    [currentlyInCartLabel setText:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"Quantity In Cart", nil), [Cart size]]];
}

- (void)initPosition
{
    position = [[Position alloc] init];
    position.item = item;
    position.quantity = 0;
    position.options = [NSMutableArray array];
    position.toppings = [NSMutableArray array];
    for (OptionSet *optionSet in item.optionSets) {
        Option *option = [optionSet.options objectAtIndex:0];
        [position.options addObject:option];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self changeQuantity:nil];
    [quantityLabel setText:NSLocalizedString(@"Quantity", nil)];
    [addToCartButton setTitle:NSLocalizedString(@"Add To Cart", nil) forState:UIControlStateNormal];
    [addToCartButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    index = NSNotFound;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadLabel];
    
    if (item != NULL) {
        return;
    }
    
    [spinner startAnimating];
    
    // `item` is not yet loaded, so disable adding to cart until it is loaded
    [addToCartButton setEnabled:NO];
    
    // Set up the object mapping
    RKObjectMapping *optionObjectMapping = [RKObjectMapping mappingForClass:[Option class]];
    [optionObjectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    [optionObjectMapping mapKeyPath:@"name_japanese" toAttribute:@"nameJapanese"];
    [optionObjectMapping mapKeyPath:@"name_english" toAttribute:@"nameEnglish"];
    [optionObjectMapping mapKeyPath:@"price_delta" toAttribute:@"priceDelta"];
    [optionObjectMapping mapKeyPath:@"item_based" toAttribute:@"itemBased"];
    
    RKObjectMapping *optionSetObjectMapping = [RKObjectMapping mappingForClass:[OptionSet class]];
    [optionSetObjectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    [optionSetObjectMapping mapKeyPath:@"name_japanese" toAttribute:@"nameJapanese"];
    [optionSetObjectMapping mapKeyPath:@"name_english" toAttribute:@"nameEnglish"];
    [optionSetObjectMapping mapKeyPath:@"options" toRelationship:@"options" withMapping:optionObjectMapping];
    
    RKObjectMapping *toppingObjectMapping = [RKObjectMapping mappingForClass:[Topping class]];
    [toppingObjectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    [toppingObjectMapping mapKeyPath:@"name_japanese" toAttribute:@"nameJapanese"];
    [toppingObjectMapping mapKeyPath:@"name_english" toAttribute:@"nameEnglish"];
    [toppingObjectMapping mapKeyPath:@"price_fixed" toAttribute:@"priceFixed"];
    [toppingObjectMapping mapKeyPath:@"price_percentage" toAttribute:@"pricePercentage"];
    [toppingObjectMapping mapKeyPath:@"description_english" toAttribute:@"descriptionEnglish"];
    [toppingObjectMapping mapKeyPath:@"description_japanese" toAttribute:@"descriptionJapanese"];
    
    RKObjectMapping *itemObjectMapping = [RKObjectMapping mappingForClass:[Item class]];
    [itemObjectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    [itemObjectMapping mapKeyPath:@"name_japanese" toAttribute:@"nameJapanese"];
    [itemObjectMapping mapKeyPath:@"name_english" toAttribute:@"nameEnglish"];
    [itemObjectMapping mapKeyPath:@"price" toAttribute:@"price"];
    [itemObjectMapping mapKeyPath:@"option_sets" toRelationship:@"optionSets" withMapping:optionSetObjectMapping];
    [itemObjectMapping mapKeyPath:@"toppings" toRelationship:@"toppings" withMapping:toppingObjectMapping];
    
    // Retrieve the item from the server
    NSString *resourcePath = [NSString stringWithFormat:@"/items/%d", itemId];
    RKObjectManager *manager = [RKObjectManager sharedManager];
    [manager loadObjectsAtResourcePath:resourcePath objectMapping:itemObjectMapping delegate:self];
}

- (IBAction)addToCart:(id)sender
{
    position.quantity = slider.value;
    Position *p = position;
    [Cart addPosition:p];
    [self initPosition];
    [self reloadLabel];
}

- (IBAction)changeQuantity:(id)sender
{
    [selectedQuantityLabel setText:[NSString stringWithFormat:@"%d", [[NSNumber numberWithDouble:slider.value] intValue]]];
}

- (IBAction)showCart:(id)sender
{
    UIViewController *cartViewController = [UIAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"CartNavigationViewController"];
    [self presentModalViewController:cartViewController animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [extrasPickerView setHidden:YES];
    [extrasTableView reloadData];
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
    if (indexPath.section == 0) {
        index = indexPath.row;
        [extrasPickerView setHidden:NO];
        [extrasPickerView reloadAllComponents];
        // Make the selected option in the picker view consistent with the option already applied to the Position
        OptionSet *optionSet = [item.optionSets objectAtIndex:index];
        for (int i = 0, n = [optionSet.options count]; i < n; i++) {
            Option *option = [optionSet.options objectAtIndex:i];
            if ([position.options containsObject:option]) {
                [extrasPickerView selectRow:i inComponent:0 animated:NO];
                break;
            }
        }
    } else if (indexPath.section == 1) {
        ToppingsViewController *toppingsViewController = [UIAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"ToppingsViewController"];
        [toppingsViewController setItem:item];
        [toppingsViewController setPosition:position];
        [self presentModalViewController:toppingsViewController animated:YES];
    }
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDataSource                                                              */
/*------------------------------------------------------------------------------------*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemExtraCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        int n = [item.optionSets count];
        if (n > 0) {
            OptionSet *optionSet = [item.optionSets objectAtIndex:indexPath.row];
            for (Option *option in position.options) {
                if ([optionSet.options containsObject:option]) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%+d円)", option.name, [option.priceDelta integerValue]];
                    break;
                }
            }
            cell.textLabel.text = optionSet.name;
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            cell.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.textLabel.text = NSLocalizedString(@"No Options", nil);
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont italicSystemFontOfSize:[UIFont systemFontSize]];
            cell.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.section == 1) {
        int n = [item.toppings count];
        if (n > 0) {
            cell.textLabel.text = NSLocalizedString(@"Add Toppings", nil);
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            cell.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.textLabel.text = NSLocalizedString(@"No Toppings", nil);
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont italicSystemFontOfSize:[UIFont systemFontSize]];
            cell.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return MAX(1, [item.optionSets count]);
    } else if (section == 1) {
        return 1;
    }
    return 0;
}

/*------------------------------------------------------------------------------------*/
/* UIPickerViewDataSource                                                             */
/*------------------------------------------------------------------------------------*/

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (index == NSNotFound) {
        return 0;
    } else {
        OptionSet *optionSet = [item.optionSets objectAtIndex:index];
        return [optionSet.options count];
    }
}

/*------------------------------------------------------------------------------------*/
/* UIPickerViewDelegate                                                               */
/*------------------------------------------------------------------------------------*/

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    OptionSet *optionSet = [item.optionSets objectAtIndex:index];
    Option *option = [optionSet.options objectAtIndex:row];
    return [NSString stringWithFormat:@"%@ (%+d円)", option.name, [option.priceDelta integerValue]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    OptionSet *optionSet = [item.optionSets objectAtIndex:index];
    Option *option = [optionSet.options objectAtIndex:row];
    for (Option *o in position.options) {
        if ([optionSet.options containsObject:o]) {
            [position.options removeObject:o];
            break;
        }
    }
    [position.options addObject:option];
}

/*------------------------------------------------------------------------------------*/
/* RKObjectLoaderDelegate                                                             */
/*------------------------------------------------------------------------------------*/

- (void)showAlert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed To Load Item", nil) message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    [spinner stopAnimating];
    
    // 'item' is now set, so it is safe to add items to the cart
    [addToCartButton setEnabled:YES];
    
    if ([[objectLoader response] isOK]) {
        item = (Item *)object;
        // Filter out empty OptionSets
        NSMutableArray *optionSets = [NSMutableArray array];
        for (OptionSet *optionSet in item.optionSets) {
            if ([optionSet.options count] > 0) {
                [optionSets addObject:optionSet];
            }
        }
        [item setOptionSets:optionSets];
        [priceLabel setText:[NSString stringWithFormat:@"¥%@", item.price]];
        [nameLabel setText:item.name];
        [categoryLabel setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Category", nil), categoryName]];
        [self initPosition];
        [extrasTableView reloadData];
    } else {
        // Should never happen - errors should result in a call to didFailWithError
        [self showAlert:NSLocalizedString(@"Load Screen Again", nil)];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [spinner stopAnimating];
    [self showAlert:[[objectLoader response] bodyAsString]];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    item = nil;
    position = nil;
    [self setQuantityLabel:nil];
    [self setNameLabel:nil];
    [self setPriceLabel:nil];
    [self setCategoryLabel:nil];
    [self setAddToCartButton:nil];
    [self setCurrentlyInCartLabel:nil];
    [self setSpinner:nil];
    [self setExtrasTableView:nil];
    [self setQuantityButton:nil];
    [self setQuantityLabel:nil];
    [self setSlider:nil];
    [self setSelectedQuantityLabel:nil];
    [self setExtrasPickerView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
