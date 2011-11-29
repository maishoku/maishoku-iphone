//
//  Cart.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/23/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "Item.h"
#import <Foundation/Foundation.h>

@interface Cart : NSObject

+ (void)addToCart:(Item *)item quantity:(NSInteger)quantity;

+ (void)removeFromCart:(Item *)item;

+ (void)updateQuantity:(Item *)item quantity:(NSInteger)quantity;

+ (void)clear;

+ (NSInteger)quantityForItem:(Item *)item;

+ (NSArray *)allItems;

@end
