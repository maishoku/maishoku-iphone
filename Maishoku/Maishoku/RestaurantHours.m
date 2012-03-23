//
//  RestaurantHours.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 3/23/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import "RestaurantHours.h"

#define LENGTH 4
#define HALF LENGTH/2

@implementation RestaurantHours

@synthesize dayName;
@synthesize openTime = _openTime;
@synthesize closeTime = _closeTime;

- (NSString *)formatTime:(NSString *)time
{
    NSString *_time;
    NSUInteger length = [time length];
    if (length < LENGTH) {
        NSString *pad = @"";
        for (int i = 0, n = LENGTH - length; i < n; i++) {
            pad = [pad stringByAppendingString:@"0"];
        }
        _time = [NSString stringWithFormat:@"%@%@", pad, time];
    } else {
        _time = time;
    }
    NSString *hour = [_time substringToIndex:HALF];
    NSString *minutes = [_time substringFromIndex:HALF];
    return [NSString stringWithFormat:@"%@:%@", hour, minutes];
}

- (void)setOpenTime:(NSString *)openTime
{
    _openTime = [self formatTime:openTime];
}

- (void)setCloseTime:(NSString *)closeTime
{
    _closeTime = [self formatTime:closeTime];
}

@end
