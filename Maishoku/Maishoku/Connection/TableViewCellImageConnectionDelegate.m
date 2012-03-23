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
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    if (image != nil) {
        tableViewCell.imageView.image = image;
        [((UITableView *)tableViewCell.superview) reloadData];
    }
    imageData = nil;
}

@end
