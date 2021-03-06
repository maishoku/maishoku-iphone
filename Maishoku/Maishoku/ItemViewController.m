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
    NSMutableData *imageData;
}

@synthesize quantityLabel;
@synthesize selectedQuantityLabel;
@synthesize addToCartButton;
@synthesize quantityButton;
@synthesize itemId;
@synthesize imageView;
@synthesize textView;
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
    [self setTitle:categoryName];
    [quantityLabel setText:NSLocalizedString(@"Quantity", nil)];
    [addToCartButton setTitle:NSLocalizedString(@"Add To Cart", nil) forState:UIControlStateNormal];
    [addToCartButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    index = NSNotFound;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadLabel];
    
    if (item != nil) {
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
    [itemObjectMapping mapKeyPath:@"description_japanese" toAttribute:@"descriptionJapanese"];
    [itemObjectMapping mapKeyPath:@"description_english" toAttribute:@"descriptionEnglish"];
    [itemObjectMapping mapKeyPath:@"default_image_url" toAttribute:@"defaultImageURL"];
    [itemObjectMapping mapKeyPath:@"thumbnail_image_url" toAttribute:@"thumbnailImageURL"];
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
/* UITextViewDelegate                                                                 */
/*------------------------------------------------------------------------------------*/

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    // UITextView doesn't respond to touch events, so we have to handle it here instead
    [extrasPickerView setHidden:YES];
    [extrasTableView reloadData];
    return NO;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    
    if (indexPath.section == 0 && [item.optionSets count] > 0) {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        // It would be great to get the width from cell.textLabel.frame.size.width, but tableView:heightForRowAtIndexPath:
        // is called before the UITableViewCell is rendered, so the width is not yet set.
        CGFloat width = 250.0;
        CGFloat singleLineSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font].height;
        CGFloat multiLineSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)].height;
        height += multiLineSize - singleLineSize;
        singleLineSize = [cell.detailTextLabel.text sizeWithFont:cell.detailTextLabel.font].height;
        multiLineSize = [cell.detailTextLabel.text sizeWithFont:cell.detailTextLabel.font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)].height;
        height += multiLineSize - singleLineSize;
    }
    
    return height;
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
        if ([item.optionSets count] > 0) {
            OptionSet *optionSet = [item.optionSets objectAtIndex:indexPath.row];
            for (Option *option in position.options) {
                if ([optionSet.options containsObject:option]) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%+d円)", option.name, [option.priceDelta integerValue]];
                    break;
                }
            }
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.text = optionSet.name;
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            cell.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.textLabel sizeToFit];
            [cell.detailTextLabel sizeToFit];
        } else {
            cell.textLabel.text = NSLocalizedString(@"No Options", nil);
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont italicSystemFontOfSize:[UIFont systemFontSize]];
            cell.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.section == 1) {
        if ([item.toppings count] > 0) {
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
    
    if ([[objectLoader response] isOK]) {
        item = (Item *)object;
        // 'item' is now set, so it is safe to add items to the cart
        [addToCartButton setEnabled:YES];
        // Filter out empty OptionSets
        NSMutableArray *optionSets = [NSMutableArray array];
        for (OptionSet *optionSet in item.optionSets) {
            if ([optionSet.options count] > 0) {
                [optionSets addObject:optionSet];
            }
        }
        [item setOptionSets:optionSets];
        [textView setText:[NSString stringWithFormat:@"%@\n¥%@\n%@", item.name, item.price, item.description]];
        [self initPosition];
        [extrasTableView reloadData];
        
        // Load the item image
        imageData = [NSMutableData data];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:item.defaultImageURL]];
        NSCachedURLResponse *response = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
        
        if (response.data == nil) {
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            if (connection == nil) {}; // get rid of "expression result unused" warning
        } else {
            UIImage *image = [[UIImage alloc] initWithData:response.data];
            if (image == nil) {
                imageView.image = UIAppDelegate.white120x120;
            } else {
                imageView.image = image;
            }
        }
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
/* NSURLConnectionDelegate                                                            */
/*------------------------------------------------------------------------------------*/

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [imageData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    imageData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    if (image == nil) {
        imageView.image = UIAppDelegate.white120x120;
    } else {
        imageView.image = image;
    }
    imageData = nil;
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    item = nil;
    position = nil;
    imageData = nil;
    [self setQuantityLabel:nil];
    [self setAddToCartButton:nil];
    [self setCurrentlyInCartLabel:nil];
    [self setSpinner:nil];
    [self setExtrasTableView:nil];
    [self setQuantityButton:nil];
    [self setQuantityLabel:nil];
    [self setSlider:nil];
    [self setSelectedQuantityLabel:nil];
    [self setExtrasPickerView:nil];
    [self setImageView:nil];
    [self setTextView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
