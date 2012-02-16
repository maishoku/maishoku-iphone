//
//  LoginViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/27/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "KeychainItemWrapper.h"
#import "TargetConditionals.h"
#import <RestKit/RestKit.h>

@implementation LoginViewController
{
    NSString *username;
    NSString *password;
}

@synthesize label;
@synthesize loginButton;
@synthesize signupButton;
@synthesize forgotPasswordButton;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize spinner;

- (void)restoreLoginButton
{
    [loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    [loginButton setEnabled:YES];
}

- (void)setLoginButtonState
{
    if ([usernameTextField.text length] == 0 || [passwordTextField.text length] == 0) {
        [loginButton setEnabled:NO];
    } else {
        [loginButton setEnabled:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLoginButtonState];
    [usernameTextField setPlaceholder:NSLocalizedString(@"Username", nil)];
    [passwordTextField setPlaceholder:NSLocalizedString(@"Password", nil)];
    [loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [signupButton setTitle:NSLocalizedString(@"Sign Up", nil) forState:UIControlStateNormal];
    [forgotPasswordButton setTitle:NSLocalizedString(@"Forgot Password", nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Uncomment the line below to test the login sequence each time the simulator launches
    //[UIAppDelegate.keychain resetKeychainItem];
    
    username = [UIAppDelegate.keychain objectForKey:(__bridge id)kSecAttrAccount];
    password = [UIAppDelegate.keychain objectForKey:(__bridge id)kSecValueData];
    
    // If the login details are stored, then authenticate using the stored details
    if ([username length] != 0 && [password length] != 0) {
        [loginButton setEnabled:NO];
        [loginButton setTitle:nil forState:UIControlStateNormal];
        [spinner startAnimating];
        [UIAppDelegate authenticate:username password:password delegate:self];
    } else {
        // Wait for user to enter their username and password...
    }
}

- (IBAction)login:(id)sender
{
    [loginButton setEnabled:NO];
    [loginButton setTitle:nil forState:UIControlStateNormal];
    [spinner startAnimating];
    
    username = usernameTextField.text;
    password = passwordTextField.text;
    
    // Now check whether the login credentials are correct
    [UIAppDelegate authenticate:username password:password delegate:self];
}

- (IBAction)signup:(id)sender
{
    UIViewController *newAddressViewController = [UIAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [newAddressViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentModalViewController:newAddressViewController animated:YES];
}

- (IBAction)forgotPassword:(id)sender
{
    NSString *protocol, *subdomain;
#if TARGET_IPHONE_SIMULATOR
    protocol = @"http";
    subdomain = @"www-dev";
#else
    protocol = @"https";
    subdomain = @"www";
#endif
    NSString *language = UIAppDelegate.displayLanguage == japanese ? @"ja" : @"en";
    NSString *url = [NSString stringWithFormat:@"%@://%@.maishoku.com/user/recovery/recovery/language/%@/", protocol, subdomain, language];
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:url]];
}

- (IBAction)usernameEditingChanged:(id)sender
{
    [self setLoginButtonState];
}

- (IBAction)passwordEditingChanged:(id)sender
{
    [self setLoginButtonState];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [usernameTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
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
    [self setLoginButtonState];
    if (textField == usernameTextField || textField == passwordTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

/*------------------------------------------------------------------------------------*/
/* RKRequestDelegate                                                                  */
/*------------------------------------------------------------------------------------*/

- (void)showAlert
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Failed", nil) message:NSLocalizedString(@"Please Try Again", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse *)response
{
    [spinner stopAnimating];
    [self restoreLoginButton];
    if ([response isOK]) {
        // Save the username and password in the keychain
        [UIAppDelegate.keychain setObject:username forKey:(__bridge id)kSecAttrAccount];
        [UIAppDelegate.keychain setObject:password forKey:(__bridge id)kSecValueData];
        // Move on to the next screen
        [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
    } else {
        [self showAlert];
    }
}

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error
{
    [spinner stopAnimating];
    [self restoreLoginButton];
    [self showAlert];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    username = nil;
    password = nil;
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [self setSpinner:nil];
    [self setLoginButton:nil];
    [self setSignupButton:nil];
    [self setLabel:nil];
    [self setForgotPasswordButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
