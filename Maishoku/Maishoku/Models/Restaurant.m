//
//  Restaurant.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Restaurant.h"
#import "DeliveryDistance.h"

@implementation Restaurant
{
    NSString *_commaSeparatedCuisines;
    NSNumber *_minimumDelivery;
}

@synthesize hours;
@synthesize cuisines;
@synthesize deliveryDistances;
@synthesize deliveryTime;
@synthesize name;
@synthesize nameJapanese;
@synthesize nameEnglish;
@synthesize phoneOrder;
@synthesize address;
@synthesize dirlogoImageURL;
@synthesize commaSeparatedCuisines;
@synthesize identifier;
@synthesize minimumOrder;
@synthesize minimumDelivery;
@synthesize distance;

- (NSString *)name
{
    return UIAppDelegate.displayLanguage == english ? nameEnglish : nameJapanese;
}

- (void)setCommaSeparatedCuisines:(NSString *)string
{
    _commaSeparatedCuisines = string;
}

- (NSString *)commaSeparatedCuisines
{
    if (_commaSeparatedCuisines != nil) {
        return _commaSeparatedCuisines;
    }
    
    NSMutableString *string = [[NSMutableString alloc] initWithString:@""];
    NSString *n = UIAppDelegate.displayLanguage == english ? @"name_english" : @"name_japanese";
    
    for (NSDictionary *dict in cuisines) {
        if ([string length] != 0) {
            [string appendString:@", "];
        }
        [string appendString:[dict objectForKey:n]];
    };
    
    _commaSeparatedCuisines = string;
    
    return string;
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
