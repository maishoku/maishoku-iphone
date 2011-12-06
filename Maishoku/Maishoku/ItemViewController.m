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
#import "ItemViewController.h"
#import <RestKit/RestKit.h>

@implementation ItemViewController
{
    Item *item;
}

@synthesize nameLabel;
@synthesize priceLabel;
@synthesize categoryLabel;
@synthesize addToCartButton;
@synthesize itemId;
@synthesize categoryName;
@synthesize quantityLabel;
@synthesize stepper;
@synthesize currentlyInCartLabel;
@synthesize spinner;

- (void)reloadLabel
{
    [currentlyInCartLabel setText:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"Quantity In Cart", nil), [Cart quantityForItem:item]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [addToCartButton setTitle:NSLocalizedString(@"Add To Cart", nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadLabel];
    
    if (item != NULL) {
        return;
    }
    
    [spinner startAnimating];
    
    // 'item' is not yet loaded, so disable adding to cart until it is loaded
    [addToCartButton setEnabled:NO];
    [addToCartButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    // Set up the Item object mapping
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[Item class]];
    [objectMapping mapKeyPath:@"name_japanese" toAttribute:@"nameJapanese"];
    [objectMapping mapKeyPath:@"name_english" toAttribute:@"nameEnglish"];
    [objectMapping mapKeyPath:@"price" toAttribute:@"price"];
    [objectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    
    // Retrieve the item from the server
    NSString *resourcePath = [NSString stringWithFormat:@"/items/%d", itemId];
    RKObjectManager *manager = [RKObjectManager sharedManager];
    [manager loadObjectsAtResourcePath:resourcePath objectMapping:objectMapping delegate:self];
}

- (IBAction)addToCart:(id)sender
{
    [Cart addToCart:item quantity:stepper.value];
    [self reloadLabel];
}

- (IBAction)changeQuantity:(id)sender
{
    [quantityLabel setText:[NSString stringWithFormat:@"%d", [[NSNumber numberWithDouble:stepper.value] intValue]]];
}

- (IBAction)showCart:(id)sender
{
    UIViewController *cartViewController = [UIAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"CartNavigationViewController"];
    [self presentModalViewController:cartViewController animated:YES];
}

/*------------------------------------------------------------------------------------*/
/* RKObjectLoaderDelegate                                                             */
/*------------------------------------------------------------------------------------*/

- (void)showAlert
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed To Load Item", nil) message:NSLocalizedString(@"Load Screen Again", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    [spinner stopAnimating];
    
    // 'item' is now set, so it is safe to add items to the cart
    [addToCartButton setEnabled:YES];
    [addToCartButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    if ([[objectLoader response] isOK]) {
        item = (Item *)object;
        [priceLabel setText:[NSString stringWithFormat:@"¥%@", item.price]];
        NSString *name = UIAppDelegate.displayLanguage == english ? item.nameEnglish : item.nameJapanese;
        [nameLabel setText:name];
        [categoryLabel setText:categoryName];
        [self reloadLabel];
    } else {
        [self showAlert];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [spinner stopAnimating];
    [self showAlert];
//    [[[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    item = nil;
    [self setStepper:nil];
    [self setQuantityLabel:nil];
    [self setNameLabel:nil];
    [self setPriceLabel:nil];
    [self setCategoryLabel:nil];
    [self setAddToCartButton:nil];
    [self setCurrentlyInCartLabel:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
