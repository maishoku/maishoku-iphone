//
//  Position.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/23/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "Item.h"
#import <Foundation/Foundation.h>

@interface Position : NSObject

@property (nonatomic, strong) Item *item;
@property (nonatomic, assign) NSInteger quantity;

@end
