//
//  AddInstructionsViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 2/1/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import "Cart.h"
#import "AppDelegate.h"
#import "AddInstructionsViewController.h"

@implementation AddInstructionsViewController

@synthesize cancelButton;
@synthesize doneButton;
@synthesize navigationBar;
@synthesize instructionsTextView;

- (void)loadView
{
    [super loadView];
    [doneButton setTintColor:MAISHOKU_RED];
    [cancelButton setTintColor:MAISHOKU_RED];
    [navigationBar setTintColor:MAISHOKU_RED];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [instructionsTextView setText:[Cart instructions]];
}

- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
    [Cart setInstructions:instructionsTextView.text];
    [self dismissModalViewControllerAnimated:YES];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    [self setInstructionsTextView:nil];
    [self setCancelButton:nil];
    [self setDoneButton:nil];
    [self setNavigationBar:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
