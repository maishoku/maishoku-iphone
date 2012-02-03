//
//  OptionSet.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 2/3/12.
//  Copyright (c) 2012 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "OptionSet.h"

@implementation OptionSet

@synthesize identifier;
@synthesize name;
@synthesize nameEnglish;
@synthesize nameJapanese;
@synthesize options;

- (NSString *)name
{
    return UIAppDelegate.displayLanguage == english ? nameEnglish : nameJapanese;
}

@end
