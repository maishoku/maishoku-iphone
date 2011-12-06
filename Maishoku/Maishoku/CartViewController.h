//
//  CartViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/23/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartViewController : UIViewController <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *restaurantLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UITableView *itemsTable;
@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;

- (IBAction)checkout:(id)sender;
- (IBAction)cancel:(id)sender;

@end
