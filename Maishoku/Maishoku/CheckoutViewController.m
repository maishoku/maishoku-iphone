//
//  CheckoutViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/23/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Cart.h"
#import "CheckoutViewController.h"
#import <RestKit/RestKit.h>
#import <RestKit/Network/RKRequestSerialization.h>

@implementation CheckoutViewController

@synthesize segmentedControl;
@synthesize confirmOrderButton;
@synthesize spinner;
@synthesize confirmedLabel;
@synthesize doneButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [segmentedControl setEnabled:NO forSegmentAtIndex:1];
    [segmentedControl setTitle:NSLocalizedString(@"Cash", nil) forSegmentAtIndex:0];
    [segmentedControl setTitle:NSLocalizedString(@"Credit Card", nil) forSegmentAtIndex:1];
    [confirmOrderButton setTitle:NSLocalizedString(@"Confirm Order", nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self valueChanged:nil];
}

- (IBAction)valueChanged:(id)sender
{
    if ([segmentedControl selectedSegmentIndex] == 0) {
        UIAppDelegate.paymentMethod = cash_on_delivery;
    } else {
        UIAppDelegate.paymentMethod = credit_card;
    }
}

- (IBAction)confirmOrder:(id)sender
{
    [confirmOrderButton setEnabled:NO];
    [confirmOrderButton setTitle:nil forState:UIControlStateNormal];
    [spinner startAnimating];
    
    /*
     * The JSON message should look like this:
     * 
     * {'restaurant_id': 9, 'payment_method': 1, 'is_delivery': True, 'items': [{'item_id': 21, 'quantity': 1}, {'item_id': 22, 'quantity': 2}]})
     */

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:4];
    
    [[Cart allItems] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *keys = [NSArray arrayWithObjects:@"item_id", @"quantity", nil];
        Item *item = (Item *)obj;
        NSNumber *itemId = [NSNumber numberWithInt:item.id];
        NSNumber *quantity = [NSNumber numberWithInt:[Cart quantityForItem:item]];
        NSArray *objects = [NSArray arrayWithObjects:itemId, quantity, nil];
        NSDictionary *itemDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [items addObject:itemDict];
    }];
    
    [dict setObject:items forKey:@"items"];
    [dict setObject:[NSNumber numberWithInt:UIAppDelegate.restaurant.id] forKey:@"restaurant_id"];
    [dict setObject:[NSNumber numberWithInt:UIAppDelegate.paymentMethod] forKey:@"payment_method"];
    [dict setObject:[NSNumber numberWithBool:UIAppDelegate.orderMethod] forKey:@"is_delivery"];
    
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
    NSString *json = [parser stringFromObject:dict error:nil];
    NSObject<RKRequestSerializable> *params = [RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
    
    [[RKClient sharedClient] post:@"/order" params:params delegate:self];
}

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

/*------------------------------------------------------------------------------------*/
/* RKRequestDelegate                                                                  */
/*------------------------------------------------------------------------------------*/

- (void)showAlert
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Order Failed", nil) message:NSLocalizedString(@"Contact Support", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

- (void)restoreButton
{
    [spinner stopAnimating];
    [confirmOrderButton setTitle:NSLocalizedString(@"Confirm Order", nil) forState:UIControlStateNormal];
    [confirmOrderButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse *)response
{
    [self restoreButton];
    if ([response isCreated]) {
        [confirmedLabel setText:[NSString stringWithFormat:@"%@\n%@.", NSLocalizedString(@"Order Confirmed", nil), UIAppDelegate.restaurant.deliveryTime]];
        [Cart clear];
        [doneButton setEnabled:YES];
    } else {
        [self showAlert];
    }
}

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error
{
    [self restoreButton];
    [self showAlert];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    [self setSegmentedControl:nil];
    [self setConfirmOrderButton:nil];
    [self setSpinner:nil];
    [self setConfirmedLabel:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
