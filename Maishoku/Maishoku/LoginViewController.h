//
//  LoginViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/27/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate, RKRequestDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)usernameEditingChanged:(id)sender;
- (IBAction)passwordEditingChanged:(id)sender;

- (IBAction)login:(id)sender;
- (IBAction)signup:(id)sender;
- (IBAction)forgotPassword:(id)sender;

@end
