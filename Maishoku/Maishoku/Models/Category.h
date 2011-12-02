//
//  Category.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/21/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Category : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *nameEnglish;
@property (nonatomic, strong) NSString *nameJapanese;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSNumber *identifier;

@end
