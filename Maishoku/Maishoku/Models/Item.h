//
//  Item.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *nameEnglish;
@property (nonatomic, strong) NSString *nameJapanese;
@property (nonatomic, strong) NSNumber *available;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *identifier;

@end
