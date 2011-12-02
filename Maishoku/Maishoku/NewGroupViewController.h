//
//  NewGroupViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 12/3/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface NewGroupViewController : UIViewController <UITextFieldDelegate, RKObjectLoaderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)cancel:(id)sender;
- (IBAction)groupNameChanged:(id)sender;
- (IBAction)submit:(id)sender;

@end
