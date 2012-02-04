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
#import "CreditCard.h"
#import <RestKit/RestKit.h>
#import <RestKit/Network/RKRequestSerialization.h>

@implementation CheckoutViewController
{
    NSMutableArray *savedCards;
}

@synthesize segmentedControl;
@synthesize confirmOrderButton;
@synthesize addInstructionsButton;
@synthesize spinner;
@synthesize confirmedLabel;
@synthesize doneButton;
@synthesize cardNumberTextField;
@synthesize expirationDateTextField;
@synthesize expirationDateLabel;
@synthesize saveCardLabel;
@synthesize saveCardSwitch;
@synthesize savedCardsTableView;
@synthesize savedCardsSpinner;
@synthesize savedCardId;

- (void)setButtonStatus
{
    if (UIAppDelegate.paymentMethod == credit_card) {
        if (savedCardId != NSNotFound || (12 <= [cardNumberTextField.text length] && 4 == [expirationDateTextField.text length])) {
            [confirmOrderButton setEnabled:YES];
        } else {
            [confirmOrderButton setEnabled:NO];
        }
    } else {
        [confirmOrderButton setEnabled:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    savedCards = [NSMutableArray array];
    [doneButton setTintColor:MAISHOKU_RED];
    [segmentedControl setTitle:NSLocalizedString(@"Cash", nil) forSegmentAtIndex:0];
    [segmentedControl setTitle:NSLocalizedString(@"Credit Card", nil) forSegmentAtIndex:1];
    [confirmOrderButton setTitle:NSLocalizedString(@"Confirm Order", nil) forState:UIControlStateNormal];
    [confirmOrderButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [addInstructionsButton setTitle:NSLocalizedString(@"Add Instructions", nil) forState:UIControlStateNormal];
    [addInstructionsButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [cardNumberTextField setPlaceholder:NSLocalizedString(@"Credit Card Number", nil)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YY"];
    NSTimeInterval oneYear = 60 * 60 * 24 * 365;
    NSString *date = [formatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:oneYear]];
    formatter = nil;
    [expirationDateTextField setPlaceholder:[NSString stringWithFormat:@"09%@", date]];
    [self setSavedCardId:NSNotFound];
    [self valueChanged:nil];
}

- (IBAction)valueChanged:(id)sender
{
    NSInteger index = [segmentedControl selectedSegmentIndex];
    switch (index) {
        case CASH:
            UIAppDelegate.paymentMethod = cash_on_delivery;
            [cardNumberTextField setHidden:YES];
            [expirationDateTextField setHidden:YES];
            [saveCardSwitch setHidden:YES];
            [savedCardsTableView setHidden:YES];
            [expirationDateLabel setText:nil];
            [saveCardLabel setText:nil];
            break;
        case CARD:
            UIAppDelegate.paymentMethod = credit_card;
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"New Card", nil), NSLocalizedString(@"Saved Card", nil), nil];
            [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
            [actionSheet showInView:[self view]];
            break;
    }
    [self setButtonStatus];
}

- (IBAction)confirmOrder:(id)sender
{
    [confirmOrderButton setEnabled:NO];
    [confirmOrderButton setTitle:nil forState:UIControlStateNormal];
    [addInstructionsButton setEnabled:NO];
    [spinner startAnimating];
    
    /*
     * The JSON message should look like this for cash payments with options and toppings:
     * 
     * {"address_id": 1, "restaurant_id": 9, "payment_method": 2, "is_delivery": false, "items": [{"item_id": 21, "quantity": 1, 'toppings': [{'id': 1}, {'id': 2}]}, {"item_id": 22, "quantity": 2, 'options': [{'id': 3}]}]}
     *
     * And like this for credit card payments with a new credit card:
     * 
     * {"address_id": 1, "restaurant_id": 9, "payment_method": 1, "is_delivery": false, "items": [{"item_id": 21, "quantity": 1}, {"item_id": 22, "quantity": 2}], "card_number": "4111111111111111", "expiration_date": "12/13", "save_card": true}
     *
     * And like this for credit card payments with a saved credit card:
     * 
     * {"address_id": 1, "restaurant_id": 9, "payment_method": 1, "is_delivery": false, "items": [{"item_id": 21, "quantity": 1}, {"item_id": 22, "quantity": 2}], "credit_card_id": 1}
     */

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *items = [NSMutableArray array];
    
    for (Position *position in [Cart allPositions]) {
        NSNumber *itemId = position.item.identifier;
        NSNumber *quantity = [NSNumber numberWithInt:position.quantity];
        NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"item_id", @"quantity", nil];
        NSMutableArray *objects = [NSMutableArray arrayWithObjects:itemId, quantity, nil];
        if ([position.toppings count] > 0) {
            [keys addObject:@"toppings"];
            NSMutableArray *toppings = [NSMutableArray array];
            for (Topping *topping in position.toppings) {
                NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObject:topping.identifier forKey:@"id"];
                [toppings addObject:d];
            }
            [objects addObject:toppings];
        }
        if ([position.options count] > 0) {
            [keys addObject:@"options"];
            NSMutableArray *options = [NSMutableArray array];
            for (Option *option in position.options) {
                NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObject:option.identifier forKey:@"id"];
                [options addObject:d];
            }
            [objects addObject:options];
        }
        NSDictionary *itemDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [items addObject:itemDict];
    };
    
    if ([Cart instructions] != nil) {
        [dict setObject:[Cart instructions] forKey:@"instructions"];
    }
    
    [dict setObject:items forKey:@"items"];
    [dict setObject:UIAppDelegate.address.identifier forKey:@"address_id"];
    [dict setObject:UIAppDelegate.restaurant.identifier forKey:@"restaurant_id"];
    [dict setObject:[NSNumber numberWithInt:UIAppDelegate.paymentMethod] forKey:@"payment_method"];
    [dict setObject:[NSNumber numberWithBool:UIAppDelegate.orderMethod] forKey:@"is_delivery"];
    
    if (UIAppDelegate.paymentMethod == credit_card) {
        if ([self savedCardId] != NSNotFound) {
            [dict setObject:[NSNumber numberWithInt:savedCardId] forKey:@"credit_card_id"];
        } else {
            [dict setObject:cardNumberTextField.text forKey:@"card_number"];
            [dict setObject:expirationDateTextField.text forKey:@"expiration_date"];
            if (saveCardSwitch.on) {
                [dict setObject:[NSNumber numberWithBool:TRUE] forKey:@"save_card"];
            }
        }
    }
    
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
    NSString *json = [parser stringFromObject:dict error:nil];
    NSObject<RKRequestSerializable> *params = [RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
    
    [[RKClient sharedClient] post:@"/orders" params:params delegate:self];
}

- (IBAction)addInstructions:(id)sender
{
    UIViewController *addInstructionsViewController = [UIAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"AddInstructionsViewController"];
    [self presentModalViewController:addInstructionsViewController animated:YES];
}

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cardNumberEditingChanged:(id)sender
{
    [self setButtonStatus];
}

- (IBAction)expirationDateEditingChanged:(id)sender
{
    [self setButtonStatus];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [cardNumberTextField resignFirstResponder];
    [expirationDateTextField resignFirstResponder];
}

- (void)dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

/*------------------------------------------------------------------------------------*/
/* UIActionSheetDelegate                                                              */
/*------------------------------------------------------------------------------------*/

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case NEW_CARD: {
            [cardNumberTextField setHidden:NO];
            [expirationDateTextField setHidden:NO];
            [saveCardSwitch setHidden:NO];
            [expirationDateLabel setText:NSLocalizedString(@"Expiration Date", nil)];
            [saveCardLabel setText:NSLocalizedString(@"Save Card", nil)];
            break;
        }
        case SAVED_CARD: {
            [savedCardsSpinner startAnimating];
            RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[CreditCard class]];
            [objectMapping mapKeyPath:@"card_number" toAttribute:@"cardNumber"];
            [objectMapping mapKeyPath:@"expiration_date" toAttribute:@"expirationDate"];
            [objectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
            [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/user/credit_cards" objectMapping:objectMapping delegate:self];
            break;
        }
        case CANCEL: {
            [segmentedControl setSelectedSegmentIndex:CASH];
            [self valueChanged:nil];
            break;
        }
    }
}

/*------------------------------------------------------------------------------------*/
/* UITextFieldDelegate                                                                */
/*------------------------------------------------------------------------------------*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self setButtonStatus];
    
    if (textField == cardNumberTextField || textField == expirationDateTextField) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger length = [string length] - range.length;
    
    if (textField == cardNumberTextField) {
        return [textField.text length] + length <= 20;
    } else if (textField == expirationDateTextField) {
        return [textField.text length] + length <= 4;
    }
    
    return YES;
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDelegate                                                                */
/*------------------------------------------------------------------------------------*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == savedCardsTableView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSUInteger row = indexPath.row;
        if (row != NSNotFound) {
            CreditCard *creditCard = [savedCards objectAtIndex:indexPath.row];
            [self setSavedCardId:[creditCard.identifier integerValue]];
            NSInteger n = [tableView numberOfRowsInSection:0];
            for (int i = 0; i < n; i++) {
                [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
            }
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            [confirmOrderButton setEnabled:YES];
        }
    }
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDataSource                                                              */
/*------------------------------------------------------------------------------------*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == savedCardsTableView && editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        NSNumber *creditCardId = ((CreditCard *)[savedCards objectAtIndex:indexPath.row]).identifier;
        NSString *resourcePath = [NSString stringWithFormat:@"/credit_cards/%@", creditCardId];
        [[RKClient sharedClient] delete:resourcePath delegate:nil]; // Should 'always' succeed, so don't care about the response
        [savedCards removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:YES];
        if ([creditCardId integerValue] == savedCardId) {
            [self setSavedCardId:NSNotFound];
            [self setButtonStatus];
        }
        [tableView endUpdates];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SavedCardCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CreditCard *creditCard = [savedCards objectAtIndex:indexPath.row];
    cell.textLabel.text = creditCard.cardNumber;
    cell.detailTextLabel.text = creditCard.expirationDate;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [savedCards count];
}

/*------------------------------------------------------------------------------------*/
/* RKRequestDelegate                                                                  */
/*------------------------------------------------------------------------------------*/

- (void)showAlert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Order Failed", nil) message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

- (void)lockDown
{
    [spinner stopAnimating];
    [Cart clear];
    [confirmOrderButton setTitle:NSLocalizedString(@"Confirm Order", nil) forState:UIControlStateNormal];
    [confirmOrderButton setEnabled:NO];
    [addInstructionsButton setEnabled:NO];
    [doneButton setEnabled:YES];
    [segmentedControl setEnabled:NO];
    [cardNumberTextField setText:nil];
    [cardNumberTextField setEnabled:NO];
    [expirationDateTextField setText:nil];
    [expirationDateTextField setEnabled:NO];
    [saveCardSwitch setEnabled:NO];
    [savedCardsTableView setHidden:YES];
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    if ([response isCreated]) {
        [self lockDown];
        [confirmedLabel setText:[NSString stringWithFormat:@"%@%@.", NSLocalizedString(@"Order Confirmed", nil), UIAppDelegate.restaurant.deliveryTime]];
    } else if ([response isOK]) {
        // Saved credit cards were loaded, ignore here
    } else {
        [spinner stopAnimating];
        [confirmOrderButton setEnabled:YES];
        [confirmOrderButton setTitle:NSLocalizedString(@"Confirm Order", nil) forState:UIControlStateNormal];
        [self showAlert:[response bodyAsString]];
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    [self lockDown];
    [self showAlert:NSLocalizedString(@"Contact Support", nil)];
}

/*------------------------------------------------------------------------------------*/
/* RKObjectLoaderDelegate                                                             */
/*------------------------------------------------------------------------------------*/

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    [savedCards removeAllObjects];
    for (CreditCard *creditCard in objects) {
        [savedCards addObject:creditCard];
    };
    [savedCardsSpinner stopAnimating];
    [savedCardsTableView setHidden:NO];
    [savedCardsTableView reloadData];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:nil message:[[objectLoader response] bodyAsString] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    savedCards = nil;
    [self setSegmentedControl:nil];
    [self setConfirmOrderButton:nil];
    [self setAddInstructionsButton:nil];
    [self setSpinner:nil];
    [self setConfirmedLabel:nil];
    [self setDoneButton:nil];
    [self setCardNumberTextField:nil];
    [self setExpirationDateTextField:nil];
    [self setExpirationDateLabel:nil];
    [self setSaveCardLabel:nil];
    [self setSaveCardSwitch:nil];
    [self setSavedCardsTableView:nil];
    [self setSavedCardsSpinner:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
