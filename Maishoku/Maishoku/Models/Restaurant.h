//
//  Restaurant.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Restaurant : NSObject

@property (nonatomic, strong) NSArray *hours;
@property (nonatomic, strong) NSArray *cuisines;
@property (nonatomic, strong) NSArray *deliveryDistances;
@property (nonatomic, strong) NSString *deliveryTime;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *nameJapanese;
@property (nonatomic, strong) NSString *nameEnglish;
@property (nonatomic, strong) NSString *phoneOrder;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *commaSeparatedCuisines;
@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSNumber *minimumOrder;
@property (nonatomic, strong) NSNumber *minimumDelivery;
@property (nonatomic, strong) NSNumber *distance;

@end
