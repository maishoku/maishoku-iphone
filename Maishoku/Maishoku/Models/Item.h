//
//  Item.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic, strong) NSArray *optionSets;
@property (nonatomic, strong) NSArray *toppings;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *nameEnglish;
@property (nonatomic, strong) NSString *nameJapanese;
@property (nonatomic, strong) NSString *descriptionEnglish;
@property (nonatomic, strong) NSString *descriptionJapanese;
@property (nonatomic, strong) NSString *defaultImageURL;
@property (nonatomic, strong) NSString *thumbnailImageURL;
@property (nonatomic, strong) NSNumber *available;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *identifier;

@end
