//
//  Option.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 1/30/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import "Option.h"
#import "AppDelegate.h"

@implementation Option

@synthesize identifier;
@synthesize itemBased;
@synthesize priceDelta;
@synthesize name;
@synthesize nameEnglish;
@synthesize nameJapanese;

- (NSString *)name
{
    return UIAppDelegate.displayLanguage == english ? nameEnglish : nameJapanese;
}

@end
