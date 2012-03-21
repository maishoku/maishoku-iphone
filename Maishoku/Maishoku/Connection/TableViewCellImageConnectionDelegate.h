//
//  TableViewCellImageConnectionDelegate.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 3/21/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewCellImageConnectionDelegate : NSObject <NSURLConnectionDelegate>

@property (nonatomic, strong) UITableViewCell *tableViewCell;

@end
