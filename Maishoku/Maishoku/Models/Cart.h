//
//  Cart.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/23/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "Item.h"
#import "Option.h"
#import "Topping.h"
#import "Position.h"
#import <Foundation/Foundation.h>

@interface Cart : NSObject

+ (void)setInstructions:(NSString *)instructions;

+ (NSString *)instructions;

+ (void)addPosition:(Position *)position;

+ (void)removePosition:(Position *)position;

+ (void)clear;

+ (NSArray *)allPositions;

+ (NSInteger)size;

@end
