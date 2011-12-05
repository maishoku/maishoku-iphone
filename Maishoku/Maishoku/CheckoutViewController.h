//
//  CheckoutViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/23/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <UIKit/UIKit.h>

#define CASH 0
#define CARD 1
#define NEW_CARD 0
#define SAVED_CARD 1
#define CANCEL 2

@interface CheckoutViewController : UIViewController <RKRequestDelegate, RKObjectLoaderDelegate, UITextFieldDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *confirmOrderButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *confirmedLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *cardNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *expirationDateTextField;
@property (weak, nonatomic) IBOutlet UILabel *expirationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *saveCardLabel;
@property (weak, nonatomic) IBOutlet UISwitch *saveCardSwitch;
@property (weak, nonatomic) IBOutlet UITableView *savedCardsTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *savedCardsSpinner;

@property (atomic) NSInteger savedCardId;

- (IBAction)valueChanged:(id)sender;
- (IBAction)confirmOrder:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)cardNumberEditingChanged:(id)sender;
- (IBAction)expirationDateEditingChanged:(id)sender;

@end
