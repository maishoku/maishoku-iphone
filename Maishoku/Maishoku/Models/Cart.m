//
//  Cart.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/23/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "Cart.h"
#import "Position.h"

@implementation Cart

static NSMutableDictionary *cart; // {itemId: position}

+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        cart = [NSMutableDictionary dictionaryWithCapacity:4];
    }
}

+ (void)addToCart:(Item *)item quantity:(NSInteger)quantity
{
    NSNumber *itemId = [NSNumber numberWithInt:item.id];
    id obj = [cart objectForKey:itemId];
    Position *position;
    if (obj) {
        position = (Position *)obj;
        position.quantity += quantity;
    } else {
        position = [[Position alloc] init];
        position.item = item;
        position.quantity = quantity;
    }
    [cart setObject:position forKey:itemId];
}

+ (void)removeFromCart:(Item *)item
{
    NSNumber *itemId = [NSNumber numberWithInt:item.id];
    [cart removeObjectForKey:itemId];
}

+ (void)updateQuantity:(Item *)item quantity:(NSInteger)quantity
{
    NSNumber *itemId = [NSNumber numberWithInt:item.id];
    id obj = [cart objectForKey:itemId];
    Position *position;
    if (obj) {
        position = (Position *)obj;
    } else {
        position = [[Position alloc] init];
        position.item = item;
    }
    position.quantity = quantity;
    [cart setObject:position forKey:itemId];
}

+ (void)clear
{
    [cart removeAllObjects];
}

+ (NSInteger)quantityForItem:(Item *)item
{
    NSNumber *itemId = [NSNumber numberWithInt:item.id];
    id obj = [cart objectForKey:itemId];
    NSInteger quantity;
    if (obj) {
        Position *position = (Position *)obj;
        quantity = position.quantity;
    } else {
        quantity = 0;
    }
    return quantity;
}

+ (NSArray *)allItems
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:4];
    [cart enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [items addObject:((Position *)obj).item];
    }];
    return items;
}

@end
