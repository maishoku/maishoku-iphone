//
//  ToppingsViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 2/1/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import "Item.h"
#import "Position.h"
#import <UIKit/UIKit.h>

@interface ToppingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) Position *position;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITableView *toppingsTableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *button;

- (IBAction)done:(id)sender;

@end
