//
//  Item.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "Item.h"
#import "AppDelegate.h"

@implementation Item

@synthesize optionSets;
@synthesize toppings;
@synthesize name;
@synthesize nameEnglish;
@synthesize nameJapanese;
@synthesize defaultImageURL;
@synthesize thumbnailImageURL;
@synthesize available;
@synthesize price;
@synthesize identifier;

- (NSString *)name
{
    return UIAppDelegate.displayLanguage == english ? nameEnglish : nameJapanese;
}

@end
