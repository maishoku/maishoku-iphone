//
//  Topping.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 1/30/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Topping : NSObject

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSNumber *priceFixed;
@property (nonatomic, strong) NSNumber *pricePercentage;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *nameEnglish;
@property (nonatomic, strong) NSString *nameJapanese;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *descriptionEnglish;
@property (nonatomic, strong) NSString *descriptionJapanese;

@end
