//
//  Topping.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 1/30/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import "Topping.h"
#import "AppDelegate.h"

@implementation Topping

@synthesize identifier;
@synthesize priceFixed;
@synthesize pricePercentage;
@synthesize name;
@synthesize nameEnglish;
@synthesize nameJapanese;
@synthesize description;
@synthesize descriptionEnglish;
@synthesize descriptionJapanese;

- (NSString *)name
{
    return UIAppDelegate.displayLanguage == english ? nameEnglish : nameJapanese;
}

- (NSString *)description
{
    return UIAppDelegate.displayLanguage == english ? descriptionEnglish : descriptionJapanese;
}

@end
