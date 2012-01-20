//
//  NewAddressViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/21/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Address.h"
#import "LocationViewController.h"
#import "NewAddressViewController.h"

@implementation NewAddressViewController

@synthesize addressLabel;
@synthesize addressTextField;
@synthesize submitButton;
@synthesize cancelButton;
@synthesize spinner;

- (void)setButtonStatus
{
    if (0 == [addressTextField.text length]) {
        [submitButton setEnabled:NO];
    } else {
        [submitButton setEnabled:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonStatus];
    [submitButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
    [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [addressLabel setText:NSLocalizedString(@"Enter New Address", nil)];
    NSString *placeholder = UIAppDelegate.displayLanguage == english ? @"Roppongi 6-10-1, Minato-ku, Tokyo" : @"東京都港区六本木６−１０−１";
    [addressTextField setPlaceholder:placeholder];
}

- (IBAction)addressEditingChanged:(id)sender
{
    [self setButtonStatus];
}

- (IBAction)submit:(id)sender
{
    [submitButton setEnabled:NO];
    [submitButton setTitle:nil forState:UIControlStateNormal];
    [spinner startAnimating];
    
    Address *address = [[Address alloc] init];
    address.address = self.addressTextField.text;
    
    RKObjectMapping *requestObjectMapping = [RKObjectMapping mappingForClass:[Address class]];
    [requestObjectMapping mapKeyPath:@"address" toAttribute:@"address"];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager.mappingProvider setSerializationMapping:requestObjectMapping forClass:[Address class]];
    
    RKObjectMapping *responseObjectMapping = [RKObjectMapping mappingForClass:[Address class]];
    [responseObjectMapping mapKeyPath:@"address" toAttribute:@"address"];
    [responseObjectMapping mapKeyPath:@"first_date" toAttribute:@"firstDate"];
    [responseObjectMapping mapKeyPath:@"last_date" toAttribute:@"lastDate"];
    [responseObjectMapping mapKeyPath:@"frequency" toAttribute:@"frequency"];
    [responseObjectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    [responseObjectMapping mapKeyPath:@"lat" toAttribute:@"lat"];
    [responseObjectMapping mapKeyPath:@"lon" toAttribute:@"lon"];
    
    [objectManager postObject:address mapResponseWith:responseObjectMapping delegate:self];
}

- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [addressTextField resignFirstResponder];
}

- (void)dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

/*------------------------------------------------------------------------------------*/
/* UITextFieldDelegate                                                                */
/*------------------------------------------------------------------------------------*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

/*------------------------------------------------------------------------------------*/
/* RKObjectLoaderDelegate                                                             */
/*------------------------------------------------------------------------------------*/

- (void)restoreButton
{
    [spinner stopAnimating];
    [submitButton setEnabled:YES];
    [submitButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
}

- (void)showAlert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed To Add New Address", nil) message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    [self restoreButton];
    if ([[objectLoader response] isCreated]) {
        [UIAppDelegate setAddressesLoaded:NO];
        [self dismissModalViewControllerAnimated:YES];
    } else {
        // Should never happen - errors should result in a call to didFailWithError
        [self showAlert:NSLocalizedString(@"Please Try Again", nil)];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [self restoreButton];
    [self showAlert:[[objectLoader response] bodyAsString]];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    [self setAddressTextField:nil];
    [self setSpinner:nil];
    [self setAddressLabel:nil];
    [self setSubmitButton:nil];
    [self setCancelButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
