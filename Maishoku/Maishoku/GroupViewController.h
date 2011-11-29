//
//  GroupViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/27/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface GroupViewController : UIViewController <RKRequestDelegate, RKObjectLoaderDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *groupsTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)addGroup:(id)sender;

@end
