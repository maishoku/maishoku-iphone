//
//  FavoritesViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface FavoritesViewController : UIViewController <RKObjectLoaderDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *favoritesTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
