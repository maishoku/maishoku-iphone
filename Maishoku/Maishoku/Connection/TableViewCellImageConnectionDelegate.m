//
//  TableViewCellImageConnectionDelegate.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 3/21/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import "TableViewCellImageConnectionDelegate.h"

@implementation TableViewCellImageConnectionDelegate
{
    NSMutableData *imageData;
}

@synthesize tableViewCell;

- (id)init
{
    self = [super init];
    if (self) {
        imageData = [NSMutableData data];
    }
    return self;
}

- (void)dealloc
{
    imageData = nil;
    tableViewCell = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [imageData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    imageData = nil;
    connection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    tableViewCell.imageView.image = [[UIImage alloc] initWithData:imageData];
    [((UITableView *)tableViewCell.superview) reloadData];
    imageData = nil;
    connection = nil;
}

@end
