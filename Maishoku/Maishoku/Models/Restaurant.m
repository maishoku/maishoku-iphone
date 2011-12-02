//
//  Restaurant.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Restaurant.h"

@implementation Restaurant
{
    NSString *_commaSeparatedCuisines;
}

@synthesize hours;
@synthesize cuisines;
@synthesize deliveryTime;
@synthesize name;
@synthesize nameJapanese;
@synthesize nameEnglish;
@synthesize phoneContact;
@synthesize address;
@synthesize commaSeparatedCuisines;
@synthesize identifier;
@synthesize minimumOrder;

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
    if (_commaSeparatedCuisines != NULL) {
        return _commaSeparatedCuisines;
    }
    
    NSMutableString *string = [[NSMutableString alloc] initWithString:@""];
    NSString *n = UIAppDelegate.displayLanguage == english ? @"name_english" : @"name_japanese";
    
    [cuisines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([string length] != 0) {
            [string appendString:@", "];
        }
        [string appendString:[(NSDictionary *)obj objectForKey:n]];
    }];
    
    _commaSeparatedCuisines = string;
    
    return string;
}

- (void)dealloc
{
    _commaSeparatedCuisines = nil;
}

@end
