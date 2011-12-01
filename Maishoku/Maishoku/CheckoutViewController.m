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
@synthesize cardNumberTextField;
@synthesize expirationDateTextField;
@synthesize securityCodeTextField;
@synthesize expirationDateLabel;
@synthesize securityCodeLabel;

- (void)setButtonStatus
{
    if (UIAppDelegate.paymentMethod == credit_card
      && (12  > [cardNumberTextField.text length]
        || 4 != [expirationDateTextField.text length]
        || 3  > [securityCodeTextField.text length]
    )) {
        [confirmOrderButton setEnabled:NO];
        [confirmOrderButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    } else {
        [confirmOrderButton setEnabled:YES];
        [confirmOrderButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [segmentedControl setTitle:NSLocalizedString(@"Cash", nil) forSegmentAtIndex:0];
    [segmentedControl setTitle:NSLocalizedString(@"Credit Card", nil) forSegmentAtIndex:1];
    [confirmOrderButton setTitle:NSLocalizedString(@"Confirm Order", nil) forState:UIControlStateNormal];
    [cardNumberTextField setPlaceholder:NSLocalizedString(@"Credit Card Number", nil)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YY"];
    NSTimeInterval oneYear = 60 * 60 * 24 * 365;
    NSString *date = [formatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:oneYear]];
    formatter = nil;
    [expirationDateTextField setPlaceholder:[NSString stringWithFormat:@"09%@", date]];
    [securityCodeTextField setPlaceholder:@"123"];
    [self valueChanged:nil];
}

- (IBAction)valueChanged:(id)sender
{
    if ([segmentedControl selectedSegmentIndex] == 0) {
        UIAppDelegate.paymentMethod = cash_on_delivery;
        [cardNumberTextField setHidden:YES];
        [expirationDateTextField setHidden:YES];
        [securityCodeTextField setHidden:YES];
        [expirationDateLabel setText:nil];
        [securityCodeLabel setText:nil];
    } else {
        UIAppDelegate.paymentMethod = credit_card;
        [cardNumberTextField setHidden:NO];
        [expirationDateTextField setHidden:NO];
        [securityCodeTextField setHidden:NO];
        [expirationDateLabel setText:NSLocalizedString(@"Expiration Date", nil)];
        [securityCodeLabel setText:NSLocalizedString(@"Security Code", nil)];
    }
    [self setButtonStatus];
}

- (IBAction)confirmOrder:(id)sender
{
    [confirmOrderButton setEnabled:NO];
    [confirmOrderButton setTitle:nil forState:UIControlStateNormal];
    [spinner startAnimating];
    
    /*
     * The JSON message should look like this for cash payments:
     * 
     * {"restaurant_id": 9, "payment_method": 2, "is_delivery": false, "items": [{"item_id": 21, "quantity": 1}, {"item_id": 22, "quantity": 2}]}
     *
     * And like this for credit card payments:
     * 
     * {"restaurant_id": 9, "payment_method": 1, "is_delivery": false, "items": [{"item_id": 21, "quantity": 1}, {"item_id": 22, "quantity": 2}], "card_number": "4111111111111111", "expiration_date": "12/13", "security_code": "1234"}
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
    
    if (UIAppDelegate.paymentMethod == credit_card) {
        [dict setObject:cardNumberTextField.text forKey:@"card_number"];
        [dict setObject:expirationDateTextField.text forKey:@"expiration_date"];
        [dict setObject:securityCodeTextField.text forKey:@"security_code"];
    }
    
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
    NSString *json = [parser stringFromObject:dict error:nil];
    NSObject<RKRequestSerializable> *params = [RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
    
    [[RKClient sharedClient] post:@"/order" params:params delegate:self];
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

- (IBAction)securityCodeEditingChanged:(id)sender
{
    [self setButtonStatus];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [cardNumberTextField resignFirstResponder];
    [expirationDateTextField resignFirstResponder];
    [securityCodeTextField resignFirstResponder];
}

/*------------------------------------------------------------------------------------*/
/* UITextFieldDelegate                                                                */
/*------------------------------------------------------------------------------------*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self setButtonStatus];
    
    if (textField == cardNumberTextField
     || textField == expirationDateTextField
     || textField == securityCodeTextField
    ) {
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
    } else if (textField == securityCodeTextField) {
        return [textField.text length] + length <= 4;
    }
    
    return YES;
}

/*------------------------------------------------------------------------------------*/
/* RKRequestDelegate                                                                  */
/*------------------------------------------------------------------------------------*/

- (void)showAlert
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Order Failed", nil) message:NSLocalizedString(@"Contact Support", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

- (void)lockDown
{
    [spinner stopAnimating];
    [Cart clear];
    [confirmOrderButton setTitle:NSLocalizedString(@"Confirm Order", nil) forState:UIControlStateNormal];
    [confirmOrderButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [confirmOrderButton setEnabled:NO];
    [doneButton setEnabled:YES];
    [segmentedControl setEnabled:NO];
    [cardNumberTextField setText:nil];
    [cardNumberTextField setEnabled:NO];
    [expirationDateTextField setText:nil];
    [expirationDateTextField setEnabled:NO];
    [securityCodeTextField setText:nil];
    [securityCodeTextField setEnabled:NO];
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    [self lockDown];
    if ([response isCreated]) {
        [confirmedLabel setText:[NSString stringWithFormat:@"%@\n%@.", NSLocalizedString(@"Order Confirmed", nil), UIAppDelegate.restaurant.deliveryTime]];
    } else {
        [self showAlert];
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    [self lockDown];
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
    [self setCardNumberTextField:nil];
    [self setExpirationDateTextField:nil];
    [self setSecurityCodeTextField:nil];
    [self setExpirationDateLabel:nil];
    [self setSecurityCodeLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
