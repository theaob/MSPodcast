//
//  MSiPhoneTableViewController.h
//  Modern Sabahlar
//
//  Created by Onur Baykal on 04.12.2012.
//  Copyright (c) 2012 Onur Baykal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MSUnplayedSwitch.h"
#import "Podcast.h"
#import "TBXML+HTTP.h"

@interface MSTableViewController : UITableViewController <NSXMLParserDelegate>

@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController * fetchResultsController;
@property (nonatomic, strong) TBXML * tbxmlParser;
@property (nonatomic, strong) Podcast * parsedPodcast;

- (IBAction)downloadButtonPressed:(UIButton *)sender;


@end
