//
//  CreditCard.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 12/2/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreditCard : NSObject

@property (nonatomic, strong) NSNumber *identifier;
@property (nonatomic, strong) NSString *cardNumber;
@property (nonatomic, strong) NSString *expirationDate;

@end
