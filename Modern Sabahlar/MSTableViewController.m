//
//  MSiPhoneTableViewController.m
//  Modern Sabahlar
//
//  Created by Onur Baykal on 04.12.2012.
//  Copyright (c) 2012 Onur Baykal. All rights reserved.
//

#import "MSTableViewController.h"
#import "MSPodcastCell.h"

@implementation MSTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError * error = nil;
    
    if( ![[self fetchResultsController] performFetch:&error] )
    {
        NSLog(@"Error!");
        abort();
    }
    
    //self.retreivePodcastsFromXML;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.fetchResultsController.sections objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"podcastCell";
    MSPodcastCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(cell == nil)
    {
        cell = [[MSPodcastCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Podcast * cellPodcast = [self.fetchResultsController objectAtIndexPath:indexPath];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    cell.podcastLabel.text = cellPodcast.title;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


#pragma mark - XML Traversing

- (void) retreivePodcastsFromXML
{
    //    NSString * podcastString = @"http://www.podcastgenerator.net/demo/pg/feed.xml";
    
    NSString * podcastString = @"http://www.radyoodtu.com.tr/podcasts/podcasts.asp?chid=1";
    
    TBXMLSuccessBlock successBlock = ^(TBXML *tbxmlDocument) {
        // If TBXML found a root node, process element and iterate all children
        if (tbxmlDocument.rootXMLElement)
            [self traverseElement:tbxmlDocument.rootXMLElement];
    };
    
    
    TBXMLFailureBlock failureBlock = ^(TBXML *tbxmlDocument, NSError * error) {
        NSLog(@"Parsing error! %@ %@", [error localizedDescription], [error userInfo]);
    };
    
    _tbxmlParser = [[TBXML alloc] initWithURL:[NSURL URLWithString:podcastString] success:successBlock failure:failureBlock];
    
}

static NSString * titleString;
static NSString * durationString;
static NSString * audioAddressString;

- (void) traverseElement:(TBXMLElement *) rootElement
{
    int counter = 1;
    
    NSEntityDescription * ped = [NSEntityDescription entityForName:@"Podcast" inManagedObjectContext:_managedObjectContext];
    
    TBXMLElement * firstItem;
    TBXMLElement * dataElement;
    
    firstItem = [TBXML childElementNamed:@"channel" parentElement:rootElement];
    
    firstItem = [TBXML childElementNamed:@"item" parentElement:firstItem];
    
    while(firstItem != nil)
    {
        dataElement = [TBXML childElementNamed:@"title" parentElement:firstItem];
        
        titleString = [TBXML textForElement:dataElement];
        
        dataElement = [TBXML childElementNamed:@"guid" parentElement:firstItem];
        
        audioAddressString = [TBXML textForElement:dataElement];
        
        dataElement = [TBXML childElementNamed:@"itunes:duration" parentElement:firstItem];
        
        durationString = [TBXML textForElement:dataElement];
        
        titleString = [titleString substringFromIndex:16];
        
        
        if(![[titleString substringToIndex:1] isEqualToString:@"~"])
        {
            _parsedPodcast = [[Podcast alloc] initWithEntity:ped insertIntoManagedObjectContext:_managedObjectContext];
            
            _parsedPodcast.title = titleString;
            _parsedPodcast.duration = durationString;
            _parsedPodcast.audioPath = audioAddressString;
            _parsedPodcast.finished = NO;
            _parsedPodcast.isPlayed = NO;
            
            [_managedObjectContext insertObject:_parsedPodcast];
        }

        firstItem = firstItem->nextSibling;
        counter++;
    }
    
    NSError * error;
    
    if(![_managedObjectContext save:&error])
    {
        NSLog(@"There was an error while saving! %@", error);
    }
    
    NSLog(@"%d", counter);
}

#pragma mark - Core Data Methods

- (NSFetchedResultsController *)fetchResultsController
{
    if(_fetchResultsController != nil)
    {
        return _fetchResultsController;
    }
    else
    {
        NSFetchRequest * request = [[NSFetchRequest alloc] init];
        NSEntityDescription * entity = [NSEntityDescription entityForName:@"Podcast" inManagedObjectContext:self.managedObjectContext];
        
        [request setEntity:entity];
        
        NSSortDescriptor * sorter = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
        
        [request setSortDescriptors:[[NSArray alloc] initWithObjects:sorter, nil]];
        
        
        
        
        _fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"title" cacheName:nil];
        
        return _fetchResultsController;
    }
}

- (void) saveData
{
    NSError * error = nil;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Could not save to managed object context!");
        NSLog(@"%@", error);
    }
    else
    {
        NSLog(@"Successfully saved new data!");
    }
}

static AVPlayer * audioPlayer;
- (IBAction)downloadButtonPressed:(UIButton *)sender
{
    NSString * mp3Path = @"http://www.radyoodtu.com.tr/podcasts/mediaredirect.asp?ch=1&itid=2848&dummy.mp3?";
    NSURL * mp3URL = [[NSURL alloc] initWithString:mp3Path];
    
    audioPlayer = [[AVPlayer alloc] initWithURL:mp3URL];

    [audioPlayer play];
}
@end
