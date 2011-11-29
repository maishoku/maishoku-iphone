//
//  NewAddressViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/21/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <UIKit/UIKit.h>

@interface NewAddressViewController : UIViewController <UITextFieldDelegate, RKObjectLoaderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)submit:(id)sender;

- (IBAction)cancel:(id)sender;

@end
