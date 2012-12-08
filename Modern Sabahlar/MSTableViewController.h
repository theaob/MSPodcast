//
//  MSiPhoneTableViewController.h
//  Modern Sabahlar
//
//  Created by Onur Baykal on 04.12.2012.
//  Copyright (c) 2012 Onur Baykal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSUnplayedSwitch.h"

@interface MSTableViewController : UITableViewController <NSXMLParserDelegate>

@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController * fetchResultsController;

@end
