//
//  RestaurantTableViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <UIKit/UIKit.h>

@interface RestaurantTableViewController : UITableViewController <RKObjectLoaderDelegate>

- (IBAction)refresh:(id)sender;

@end
