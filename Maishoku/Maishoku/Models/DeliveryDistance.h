//
//  DeliveryDistance.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 2/16/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeliveryDistance : NSObject

@property (nonatomic, strong) NSNumber *lowerBound;
@property (nonatomic, strong) NSNumber *upperBound;
@property (nonatomic, strong) NSNumber *minimumDelivery;

@end
