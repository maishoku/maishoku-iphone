//
//  Favorite.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 12/6/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Favorite.h"

@implementation Favorite

@synthesize name;
@synthesize restaurantName;
@synthesize restaurantNameEnglish;
@synthesize restaurantNameJapanese;
@synthesize items;
@synthesize identifier;

- (NSString *)restaurantName
{
    return UIAppDelegate.displayLanguage == english ? restaurantNameEnglish : restaurantNameJapanese;
}

@end
