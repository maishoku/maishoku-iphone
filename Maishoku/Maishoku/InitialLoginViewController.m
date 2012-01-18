//
//  InitialLoginViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/3/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "InitialLoginViewController.h"

@implementation InitialLoginViewController

@synthesize spinner;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [spinner startAnimating];
    
    // Uncomment the line below to test the login sequence each time the simulator launches
    //[UIAppDelegate.keychain resetKeychainItem];
    
    NSString *username = [UIAppDelegate.keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString *password = [UIAppDelegate.keychain objectForKey:(__bridge id)kSecValueData];
    
    if ([username length] != 0 && [password length] != 0) {
        // If the login details are stored, then authenticate using the stored details
        [UIAppDelegate authenticate:username password:password delegate:self];
    } else {
        // Otherwise segue to the screen where the user can enter their login details
        [self performSegueWithIdentifier:@"InitialLoginSegue" sender:nil];
    }
}

- (void)dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

/*------------------------------------------------------------------------------------*/
/* RKRequestDelegate                                                                  */
/*------------------------------------------------------------------------------------*/

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse *)response {
    [spinner stopAnimating];
    if ([response isOK]) {
        [self performSegueWithIdentifier:@"BypassLoginSegue" sender:nil];
    } else {
        // The stored login details did not successfully authenticate, so reset them
        [UIAppDelegate.keychain resetKeychainItem];
        [self performSegueWithIdentifier:@"InitialLoginSegue" sender:nil];
    }
}

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
    [spinner stopAnimating];
    // The stored login details did not successfully authenticate, so reset them
    [UIAppDelegate.keychain resetKeychainItem];
    [self performSegueWithIdentifier:@"InitialLoginSegue" sender:nil];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    [self setSpinner:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
