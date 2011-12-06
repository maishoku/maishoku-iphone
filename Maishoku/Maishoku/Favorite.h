//
//  Favorite.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 12/6/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Favorite : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong, readonly) NSString *restaurantName;
@property (nonatomic, strong) NSString *restaurantNameEnglish;
@property (nonatomic, strong) NSString *restaurantNameJapanese;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSNumber *identifier;

@end
