//
//  NewGroupViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 12/3/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "Group.h"
#import "NewGroupViewController.h"

@implementation NewGroupViewController

@synthesize groupNameLabel;
@synthesize groupNameTextField;
@synthesize submitButton;
@synthesize spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [groupNameLabel setText:NSLocalizedString(@"Group Name", nil)];
    [groupNameTextField setPlaceholder:NSLocalizedString(@"Awesome Group", nil)];
    [submitButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
    [self groupNameChanged:nil];
}

- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)groupNameChanged:(id)sender
{
    NSString *text = groupNameTextField.text;
    
    if ([text length] > 0) {
        [submitButton setEnabled:YES];
        [submitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else {
        [submitButton setEnabled:NO];
        [submitButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
    [self.navigationItem setTitle:text];
}

- (IBAction)submit:(id)sender
{
    [submitButton setEnabled:NO];
    [submitButton setTitle:nil forState:UIControlStateNormal];
    [spinner startAnimating];
    
    Group *group = [[Group alloc] init];
    group.name = groupNameTextField.text;
    
    RKObjectMapping *requestObjectMapping = [RKObjectMapping mappingForClass:[Group class]];
    [requestObjectMapping mapKeyPath:@"name" toAttribute:@"name"];
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    [objectManager.mappingProvider setSerializationMapping:requestObjectMapping forClass:[Group class]];
    
    RKObjectMapping *responseObjectMapping = [RKObjectMapping mappingForClass:[Group class]];
    [responseObjectMapping mapKeyPath:@"name" toAttribute:@"name"];
    
    [objectManager postObject:group mapResponseWith:responseObjectMapping delegate:self];
}

/*------------------------------------------------------------------------------------*/
/* UITextFieldDelegate                                                                */
/*------------------------------------------------------------------------------------*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == nil) {
        [textField resignFirstResponder];
    }
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
    [[[UIAlertView alloc] initWithTitle:@"Failed To Create New Group" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
//    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed To Create New Group", nil) message:NSLocalizedString(@"Please Try Again", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    [self restoreButton];
    if ([[objectLoader response] isCreated]) {
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
    [self setGroupNameLabel:nil];
    [self setGroupNameTextField:nil];
    [self setSubmitButton:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
