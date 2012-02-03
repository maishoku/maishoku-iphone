//
//  ItemViewController.h
//  Maishoku
//
//  Created by Jonathan Sweemer on 11/21/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface ItemViewController : UIViewController <RKObjectLoaderDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedQuantityLabel;
@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;
@property (weak, nonatomic) IBOutlet UIButton *quantityButton;
@property (weak, nonatomic) IBOutlet UILabel *currentlyInCartLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UITableView *extrasTableView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIPickerView *extrasPickerView;
@property (weak, nonatomic) NSString *categoryName;
@property (assign, nonatomic) NSInteger itemId;

- (IBAction)addToCart:(id)sender;

- (IBAction)changeQuantity:(id)sender;

- (IBAction)showCart:(id)sender;

@end
