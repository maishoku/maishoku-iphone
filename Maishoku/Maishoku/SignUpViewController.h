//
//  SignUpViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/24/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, RKRequestDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField1;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField2;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)submit:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)usernameEditingChanged:(id)sender;
- (IBAction)password1EditingChanged:(id)sender;
- (IBAction)password2EditingChanged:(id)sender;
- (IBAction)emailEditingChanged:(id)sender;
- (IBAction)phoneNumberEditingChanged:(id)sender;

@end
