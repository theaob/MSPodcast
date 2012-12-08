//
//  MSiPhoneTableViewController.m
//  Modern Sabahlar
//
//  Created by Onur Baykal on 04.12.2012.
//  Copyright (c) 2012 Onur Baykal. All rights reserved.
//

#import "MSTableViewController.h"
#import "Podcast.h"
#import "MSPodcastCell.h"

@interface MSTableViewController ()

@property NSXMLParser *parser;

@end

@implementation MSTableViewController

@synthesize parser = _parser;

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
        
    Podcast * p = [NSEntityDescription insertNewObjectForEntityForName:@"Podcast" inManagedObjectContext:_managedObjectContext];
    p.date = [NSDate date];
    
    [self.managedObjectContext insertObject:podcast];

//    NSURL * podcastURL;
//    
//    if(!_parser)
//    {
//        podcastURL = [[NSURL alloc] initWithString:@"http://www.radyoodtu.com.tr/podcasts/podcasts.asp?chid=1"];
//        _parser = [[NSXMLParser alloc] initWithContentsOfURL:podcastURL];
//    }
//    
//    [_parser setDelegate:self];
//    
//    if(podcastURL != nil)
//    {
//    BOOL success = [_parser parse];
//    
//    if(success)
//    {
//        NSLog(@"Parsing Successful");
//    }
//    else
//    {
//        NSLog(@"Parsing Failed!");
//    }
//    }
//    else
//    {
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Podcast server is not responding!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
//        
//        [alert show];
//    }
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
    
    cell.podcastLabel.text = cellPodcast.date.description;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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


#pragma mark - XML Parsing delegation

static BOOL startedItem = NO;
static BOOL startedMediaAddress = NO;
static BOOL startedTitle = NO;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"item"])
    {
        startedItem = YES;
    }
    else if([elementName isEqualToString:@"guid"])
    {
        startedMediaAddress = YES;
    }
    else if( [elementName isEqualToString:@"title"] )
    {
        startedTitle = YES;
    }
}

static NSString * path;
static Podcast * podcast;

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if( startedMediaAddress )
    {
        path = [NSString stringWithFormat:@"%@%@",path, string];
        podcast.audioPath = path;
    }
    else if(startedTitle)
    {
        
        path = [[NSString alloc] init];
        podcast = [NSEntityDescription insertNewObjectForEntityForName:@"Podcast" inManagedObjectContext:_managedObjectContext];
        
    }
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"item"])
    {
        startedItem = NO;
    }
    else if([elementName isEqualToString:@"guid"])
    {
        NSLog(@"%@", path);
        startedMediaAddress = NO;
    }
    else if( [elementName isEqualToString:@"title"] )
    {
        startedTitle = NO;
    }
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
        
        NSSortDescriptor * sorter = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        
        [request setSortDescriptors:[[NSArray alloc] initWithObjects:sorter, nil]];
        
        
        
        
        _fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"date" cacheName:nil];
        
        return _fetchResultsController;
    }
}

- (IBAction)downloadButton:(id)sender {
}
@end
