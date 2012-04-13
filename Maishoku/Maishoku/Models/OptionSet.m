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
    NSRange range;
    NSString *string = [(UIAppDelegate.displayLanguage == english ? nameEnglish : nameJapanese) copy];
    while ((range = [string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        string = [string stringByReplacingCharactersInRange:range withString:@""];
    }
    return string;
}

@end
