//
//  GroupViewController.m
//  Maishoku
//
//  Created by Jonathan Sweemer on 10/27/11.
//  Copyright (c) 2011 Dynaptico LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Group.h"
#import "GroupViewController.h"
#import <RestKit/RestKit.h>

@implementation GroupViewController
{
    NSMutableArray *groups;
}

@synthesize groupsTable;
@synthesize spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    groups = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [spinner startAnimating];
    
    // Set up the Group object mapping
    RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[Group class]];
    [objectMapping mapKeyPath:@"name" toAttribute:@"name"];
    [objectMapping mapKeyPath:@"id" toAttribute:@"identifier"];
    
    // Retrieve the list of restaurants from the server
    RKObjectManager *manager = [RKObjectManager sharedManager];
    [manager loadObjectsAtResourcePath:@"/user/groups" objectMapping:objectMapping delegate:self];
}

- (IBAction)addGroup:(id)sender
{
    UIViewController *newAddressViewController = [UIAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"NewGroupViewController"];
    [self presentModalViewController:newAddressViewController animated:YES];
}

- (void)dealloc
{
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDelegate                                                                */
/*------------------------------------------------------------------------------------*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSUInteger row = indexPath.row;
    if (row != NSNotFound) {
//        UIAppDelegate.group = [groups objectAtIndex:row];
//        [self performSegueWithIdentifier:@"GroupViewSegue" sender:nil];
    }
}

/*------------------------------------------------------------------------------------*/
/* UITableViewDataSource                                                              */
/*------------------------------------------------------------------------------------*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Group *group = [groups objectAtIndex:indexPath.row];
    cell.textLabel.text = group.name;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [groups count];
}

/*------------------------------------------------------------------------------------*/
/* RKObjectLoaderDelegate                                                             */
/*------------------------------------------------------------------------------------*/

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    [groups removeAllObjects];
    for (Group *group in objects) {
        [groups addObject:group];
    };
//    [UIAppDelegate setGroupsLoaded:YES];
    [spinner stopAnimating];
    [groupsTable reloadData];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [spinner stopAnimating];
    [[[UIAlertView alloc] initWithTitle:nil message:[[objectLoader response] bodyAsString] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

/*------------------------------------------------------------------------------------*/
/* XCode-generated stuff below                                                        */
/*------------------------------------------------------------------------------------*/

- (void)viewDidUnload
{
    groups = nil;
    [self setGroupsTable:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
