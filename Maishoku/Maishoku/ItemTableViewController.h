//
//  ItemTableViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <UIKit/UIKit.h>

@interface ItemTableViewController : UITableViewController <RKObjectLoaderDelegate>

- (IBAction)showCart:(id)sender;

@end
