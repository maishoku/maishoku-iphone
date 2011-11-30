//
//  AppDelegate.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/27/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "Address.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "KeychainItemWrapper.h"
#import "TargetConditionals.h"
#import <RestKit/RestKit.h>

@implementation AppDelegate
{
	Reachability *reachabilityWithHostName;
}

@synthesize window;
@synthesize keychain;
@synthesize address;
@synthesize restaurant;
@synthesize orderMethod;
@synthesize paymentMethod;
@synthesize displayLanguage;
@synthesize storyboard;
@synthesize addressesLoaded;
@synthesize restaurantsLoaded;

// Called by Reachability whenever status changes
- (void)reachabilityChanged:(NSNotification *)notification
{
	Reachability *reachability = [notification object];
    if (reachability == reachabilityWithHostName) {
        NetworkStatus currentReachabilityStatus = [reachability currentReachabilityStatus];
        if (currentReachabilityStatus == NotReachable || [reachability connectionRequired]) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", nil) message:NSLocalizedString(@"Check Connection", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Cache the language to display for items and restaurants received from the server
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    if ([preferredLanguages count] == 0 || [((NSString *)[preferredLanguages objectAtIndex:0]) isEqualToString:@"en"]) {
        displayLanguage = english;
    } else {
        displayLanguage = japanese;
    }
    
    // Pre-instantiate the RKClient and RKObjectManager. They can now be accessed anywhere via
    // [RKClient sharedClient] and [RKObjectManager sharedManager]
    RKObjectManager *objectManager;
    
#if TARGET_IPHONE_SIMULATOR
    //[RKClient clientWithBaseURL:[NSString stringWithFormat:@"http://api.local/%@", API_VERSION]];
    //objectManager = [RKObjectManager objectManagerWithBaseURL:[NSString stringWithFormat:@"http://api.local/%@", API_VERSION]];
    [RKClient clientWithBaseURL:[NSString stringWithFormat:@"http://api-dev.maishoku.com/%@", API_VERSION]];
    objectManager = [RKObjectManager objectManagerWithBaseURL:[NSString stringWithFormat:@"http://api-dev.maishoku.com/%@", API_VERSION]];
	reachabilityWithHostName = [Reachability reachabilityWithHostName: @"api-dev.maishoku.com"];
#else
    [RKClient clientWithBaseURL:[NSString stringWithFormat:@"https://api.maishoku.com/%@", API_VERSION]];
    objectManager = [RKObjectManager objectManagerWithBaseURL:[NSString stringWithFormat:@"https://api.maishoku.com/%@", API_VERSION]];
	reachabilityWithHostName = [Reachability reachabilityWithHostName: @"api.maishoku.com"];
#endif
    
    objectManager.serializationMIMEType = RKMIMETypeJSON;
    
    // Store the username and password in the keychain
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Password" accessGroup:nil];
    self.keychain = wrapper;
    
    // Store the storyboard, so that we can use it to instantiate view controllers from storyboard elements
    self.storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    // Set up routing for models that require it
    RKObjectRouter *router = [objectManager router];
    [router routeClass:[Address class] toResourcePath:@"/user/address"];
    
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method "reachabilityChanged" will be called.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
	[reachabilityWithHostName startNotifier];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [[url path] isEqualToString:@"/launch"];
}

- (void)authenticate:(NSString *)username password:(NSString *)password delegate:(id)delegate
{
    // Use HTTP Basic Authentication for the shared RKClient
    RKClient *client = [RKClient sharedClient];
    client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    client.username = username;
    client.password = password;
    
    // Use HTTP Basic Authentication for the shared RKObjectManager
    RKObjectManager *manager = [RKObjectManager sharedManager];
    manager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
    manager.client.username = username;
    manager.client.password = password;
    
    [client get:@"/authenticate" delegate:delegate];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
