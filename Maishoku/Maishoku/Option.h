//
//  Option.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 1/30/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Option : NSObject

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSNumber *itemBased;
@property (nonatomic, strong) NSNumber *priceDelta;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *nameEnglish;
@property (nonatomic, strong) NSString *nameJapanese;

@end
