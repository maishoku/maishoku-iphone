//
//  SignUpViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/24/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "SignUpViewController.h"
#import <RestKit/RestKit.h>
#import <RestKit/Network/RKRequestSerialization.h>

@implementation SignUpViewController

@synthesize usernameTextField;
@synthesize passwordTextField1;
@synthesize passwordTextField2;
@synthesize emailTextField;
@synthesize phoneNumberTextField;
@synthesize submitButton;
@synthesize toolbar;
@synthesize spinner;

- (void)setButtonStatus
{
    if (0 == [usernameTextField.text length]
     || 0 == [passwordTextField1.text length]
     || 0 == [passwordTextField2.text length]
     || 0 == [emailTextField.text length]
     || 0 == [phoneNumberTextField.text length]
    ) {
        [submitButton setEnabled:NO];
        [submitButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    } else {
        [submitButton setEnabled:YES];
        [submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [submitButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
    [usernameTextField setPlaceholder:NSLocalizedString(@"Username", nil)];
    [passwordTextField1 setPlaceholder:NSLocalizedString(@"Password", nil)];
    [passwordTextField2 setPlaceholder:NSLocalizedString(@"Password Confirm", nil)];
    [emailTextField setPlaceholder:NSLocalizedString(@"Email", nil)];
    [phoneNumberTextField setPlaceholder:NSLocalizedString(@"Phone Number", nil)];
    [self setButtonStatus];
}

//static NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
static NSString *emailRegex =
@"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
@"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
@"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";

- (IBAction)submit:(id)sender
{
    NSString *username = usernameTextField.text;
    NSString *password = passwordTextField1.text;
    NSString *email = emailTextField.text;
    NSString *phoneNumber = phoneNumberTextField.text;
    
    // Bit o' validation
    if (![password isEqualToString:passwordTextField2.text]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Passwords Are Not Same", nil) message:NSLocalizedString(@"Please Try Again", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        return;
    }
    if (![phoneNumber hasPrefix:@"0"] || [phoneNumber length] < 10) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Phone Number Invalid", nil) message:NSLocalizedString(@"Phone Number Format", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        return;
    }
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (![emailTest evaluateWithObject:email]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email Invalid", nil) message:NSLocalizedString(@"Please Enter Valid Email", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        return;
    }
    
    [submitButton setEnabled:NO];
    [submitButton setTitle:nil forState:UIControlStateNormal];
    [spinner startAnimating];
    
    /*
     * The JSON message should look like this:
     * 
     * {'username': username, 'password': password, 'email': email, 'phone_number': phoneNumber}
     */

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    [dict setObject:username forKey:@"username"];
    [dict setObject:password forKey:@"password"];
    [dict setObject:email forKey:@"email"];
    [dict setObject:phoneNumber forKey:@"phone_number"];
    
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
    NSString *json = [parser stringFromObject:dict error:nil];
    NSObject<RKRequestSerializable> *params = [RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
    
    [[RKClient sharedClient] post:@"/user" params:params delegate:self];
}

- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)usernameEditingChanged:(id)sender
{
    [self setButtonStatus];
}

- (IBAction)password1EditingChanged:(id)sender
{
    [self setButtonStatus];
}

- (IBAction)password2EditingChanged:(id)sender
{
    [self setButtonStatus];
}

- (IBAction)emailEditingChanged:(id)sender
{
    [self setButtonStatus];
}

- (IBAction)phoneNumberEditingChanged:(id)sender
{
    [self setButtonStatus];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [usernameTextField resignFirstResponder];
    [passwordTextField1 resignFirstResponder];
    [passwordTextField2 resignFirstResponder];
    [emailTextField resignFirstResponder];
    [phoneNumberTextField resignFirstResponder];
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
    [self setButtonStatus];
    
    if (textField == usernameTextField
     || textField == passwordTextField1
     || textField == passwordTextField2
     || textField == emailTextField
     || textField == phoneNumberTextField
    ) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

/*------------------------------------------------------------------------------------*/
/* UIAlertViewDelegate                                                                */
/*------------------------------------------------------------------------------------*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissModalViewControllerAnimated:YES];
}

/*------------------------------------------------------------------------------------*/
/* RKRequestDelegate                                                                  */
/*------------------------------------------------------------------------------------*/

- (void)restoreButton
{
    [spinner stopAnimating];
    [submitButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
    [submitButton setEnabled:YES];
}

- (void)showAlert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse *)response
{
    [self restoreButton];
    if ([response isCreated]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign Up Complete", nil) message:NSLocalizedString(@"Check Your Email", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    } else {
        [self showAlert:[response bodyAsString]];
    }
}

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error
{
    [self restoreButton];
    [self showAlert:[error localizedFailureReason]];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    [self setSubmitButton:nil];
    [self setUsernameTextField:nil];
    [self setPasswordTextField1:nil];
    [self setPasswordTextField2:nil];
    [self setToolbar:nil];
    [self setSpinner:nil];
    [self setEmailTextField:nil];
    [self setPhoneNumberTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
