//
//  AppDelegate.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/27/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "Item.h"
#import "Address.h"
#import "Restaurant.h"
#import "KeychainItemWrapper.h"
#import <UIKit/UIKit.h>

#define UIAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define API_VERSION @"1.0"

#define MAISHOKU_RED [UIColor colorWithRed:0.7843 green:0.0 blue:0.0 alpha:1.0]

enum OrderMethod {
    delivery = TRUE, pickup = FALSE
};

enum PaymentMethod {
    credit_card = 1, cash_on_delivery = 2
};

enum DisplayLanguage {
    english = 1, japanese = 2
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *storyboard;
@property (nonatomic, retain) KeychainItemWrapper *keychain;
@property (atomic, retain) Address *address;
@property (atomic, retain) Restaurant *restaurant;
@property (nonatomic) enum OrderMethod orderMethod;
@property (nonatomic) enum PaymentMethod paymentMethod;
@property (nonatomic) enum DisplayLanguage displayLanguage;
@property (atomic) BOOL addressesLoaded;
@property (atomic) BOOL restaurantsLoaded;

- (void)authenticate:(NSString *)username password:(NSString *)password delegate:(id)delegate;

@end
