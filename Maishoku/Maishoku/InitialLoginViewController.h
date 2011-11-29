//
//  InitialLoginViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/3/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <UIKit/UIKit.h>

@interface InitialLoginViewController : UIViewController <RKRequestDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
