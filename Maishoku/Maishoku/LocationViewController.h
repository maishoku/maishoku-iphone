//
//  LocationViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/31/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationViewController : UIViewController <CLLocationManagerDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, RKObjectLoaderDelegate, RKRequestDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITableView *addressView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *addNewAddressButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *locateButton;
@property (atomic) BOOL viewPresented;

- (IBAction)addAddress:(id)sender;

- (IBAction)logout:(id)sender;

- (IBAction)valueChanged:(id)sender;

- (IBAction)locate:(id)sender;

@end
