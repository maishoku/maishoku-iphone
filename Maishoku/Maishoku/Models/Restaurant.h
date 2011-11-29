//
//  Restaurant.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/28/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Restaurant : NSObject

@property (nonatomic, retain) NSArray *hours;
@property (nonatomic, retain) NSArray *cuisines;
@property (nonatomic, retain) NSString *deliveryTime;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *nameJapanese;
@property (nonatomic, retain) NSString *nameEnglish;
@property (nonatomic, retain) NSString *phoneContact;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *commaSeparatedCuisines;
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger minimumOrder;

@end
