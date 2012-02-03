//
//  AddInstructionsViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 2/1/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddInstructionsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITextView *instructionsTextView;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
