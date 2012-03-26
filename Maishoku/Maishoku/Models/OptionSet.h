//
//  OptionSet.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 2/3/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OptionSet : NSObject

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *nameEnglish;
@property (nonatomic, strong) NSString *nameJapanese;
@property (nonatomic, strong) NSArray *options;

@end
