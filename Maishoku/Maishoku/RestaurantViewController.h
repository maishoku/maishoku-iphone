//
//  RestaurantViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/27/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantViewController : UIViewController <UITableViewDataSource, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIButton *seeItemsButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UITableView *restaurantInfoTableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cuisinesLabel;

- (IBAction)seeItems:(id)sender;
- (IBAction)showCart:(id)sender;

@end
