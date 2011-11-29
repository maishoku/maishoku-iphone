//
//  CheckoutViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/23/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <UIKit/UIKit.h>

@interface CheckoutViewController : UIViewController <RKRequestDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *confirmOrderButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *confirmedLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)valueChanged:(id)sender;

- (IBAction)confirmOrder:(id)sender;

- (IBAction)done:(id)sender;

@end
