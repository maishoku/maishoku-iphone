//
//  Address.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/1/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *lastDate;
@property (nonatomic, strong) NSDate *firstDate;
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSNumber *frequency;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lon;

@end
