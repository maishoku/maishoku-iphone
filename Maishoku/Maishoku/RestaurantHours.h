//
//  RestaurantHours.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 3/23/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestaurantHours : NSObject

@property (nonatomic, strong) NSString *dayName;
@property (nonatomic, strong) NSString *openTime;
@property (nonatomic, strong) NSString *closeTime;

@end
