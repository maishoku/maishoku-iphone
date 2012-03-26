//
//  Restaurant.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Restaurant.h"
#import "RestaurantHours.h"
#import "DeliveryDistance.h"

@implementation Restaurant

@synthesize hours;
@synthesize cuisines;
@synthesize deliveryDistances;
@synthesize deliveryTime;
@synthesize name;
@synthesize nameJapanese;
@synthesize nameEnglish;
@synthesize descriptionJapanese;
@synthesize descriptionEnglish;
@synthesize phoneOrder;
@synthesize address;
@synthesize dirlogoImageURL;
@synthesize mainlogoImageURL;
@synthesize todaysHours;
@synthesize commaSeparatedCuisines = _commaSeparatedCuisines;
@synthesize identifier;
@synthesize minimumOrder;
@synthesize minimumDelivery = _minimumDelivery;
@synthesize distance;

- (NSString *)name
{
    return UIAppDelegate.displayLanguage == english ? nameEnglish : nameJapanese;
}

- (NSString *)description
{
    return UIAppDelegate.displayLanguage == english ? descriptionEnglish : descriptionJapanese;
}

- (NSString *)todaysHours
{
    NSString *h = NSLocalizedString(@"Closed", nil);
    NSString *dayName = [UIAppDelegate todaysDateEEE];
    NSMutableArray *hoursArray = [NSMutableArray array];
    for (RestaurantHours *rh in hours) {
        if ([rh.dayName isEqualToString:dayName]) {
            [hoursArray addObject:[NSString stringWithFormat:@"%@ - %@", rh.openTime, rh.closeTime]];
        }
    }
    if ([hoursArray count] > 0) {
        NSArray *sortedArray = [hoursArray sortedArrayUsingComparator:^(id a, id b) {
            NSString *first = [(NSString *)a substringToIndex:2];
            NSString *second = [(NSString *)b substringToIndex:2];
            if (first > second) {
                return 1;
            } else if (first < second) {
                return -1;
            } else {
                return 0;
            }
        }];
        h = [sortedArray componentsJoinedByString:@", "];
    }
    return h;
}

- (NSString *)commaSeparatedCuisines
{
    if (_commaSeparatedCuisines == nil) {
        NSMutableString *string = [[NSMutableString alloc] initWithString:@""];
        NSString *n = UIAppDelegate.displayLanguage == english ? @"name_english" : @"name_japanese";
        for (NSDictionary *dict in cuisines) {
            if ([string length] != 0) {
                [string appendString:@", "];
            }
            [string appendString:[dict objectForKey:n]];
        };
        _commaSeparatedCuisines = string;
    }
    
    return _commaSeparatedCuisines;
}

- (NSNumber *)minimumDelivery
{
    if (_minimumDelivery != nil) {
        return _minimumDelivery;
    }
    
    _minimumDelivery = minimumOrder;
    
    NSArray *sortedDeliveryDistances = [deliveryDistances sortedArrayUsingComparator:^(id a, id b) {
        double first = [[(DeliveryDistance *)a upperBound] doubleValue];
        double second = [[(DeliveryDistance *)b upperBound] doubleValue];
        if (first > second) {
            return 1;
        } else if (first < second) {
            return -1;
        } else {
            return 0;
        }
    }];
    
    for (DeliveryDistance *deliveryDistance in sortedDeliveryDistances) {
        if ([distance doubleValue] <= [deliveryDistance.upperBound doubleValue]) {
            _minimumDelivery = deliveryDistance.minimumDelivery;
            break;
        }
    }
    
    return _minimumDelivery;
}

- (void)dealloc
{
    _commaSeparatedCuisines = nil;
    _minimumDelivery = nil;
}

@end
