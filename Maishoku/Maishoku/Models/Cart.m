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

static NSString *_instructions;
static NSMutableArray *positions; // array of Position objects

+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        positions = [NSMutableArray array];
    }
}

+ (void)setInstructions:(NSString *)instructions
{
    _instructions = instructions;
}

+ (NSString *)instructions
{
    return _instructions;
}

+ (void)addPosition:(Position *)position
{
    [positions addObject:position];
}

+ (void)removePosition:(Position *)position
{
    [positions removeObject:position];
}

+ (void)clear;
{
    _instructions = nil;
    [positions removeAllObjects];
}

+ (NSArray *)allPositions
{
    return positions;
}

+ (NSInteger)size
{
    NSInteger n = 0;
    for (Position *position in positions) {
        n += position.quantity;
    }
    return n;
}

@end
