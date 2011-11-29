//
//  FavoritesViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface FavoritesViewController : UIViewController <RKRequestDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *itemsTable;

@end
