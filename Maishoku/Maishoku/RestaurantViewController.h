//
//  RestaurantViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/27/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *minimumOrderLabel;
@property (weak, nonatomic) IBOutlet UILabel *cuisinesLabel;
@property (weak, nonatomic) IBOutlet UIButton *seeItemsButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

- (IBAction)seeItems:(id)sender;

- (IBAction)showCart:(id)sender;

@end
