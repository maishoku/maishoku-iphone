//
//  Category.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/21/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Category.h"

@implementation Category

@synthesize name;
@synthesize nameEnglish;
@synthesize nameJapanese;
@synthesize items;
@synthesize id;

- (NSString *)name
{
    return UIAppDelegate.displayLanguage == english ? nameEnglish : nameJapanese;
}

@end
