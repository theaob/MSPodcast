//
//  MSiPhoneTableViewController.m
//  Modern Sabahlar
//
//  Created by Onur Baykal on 04.12.2012.
//  Copyright (c) 2012 Onur Baykal. All rights reserved.
//

#import "MSTableViewController.h"
#import "MSPodcastCell.h"
#import "GSProgressView.h"

@implementation MSTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setDataSource:self];
    
    if( _statusOverlay == nil )
    {
        _statusOverlay = [BWStatusBarOverlay shared];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [BWStatusBarOverlay setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.Mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"Loading",@"Displayed when fetching podcast XML");
    
    self.shouldSaveData = NO;
    
    NSError * error = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Podcast" inManagedObjectContext:_managedObjectContext];
    
    NSSortDescriptor * sorter = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sorter, nil]];
    [fetchRequest setFetchLimit:1];
    
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"%@! %@",NSLocalizedString(@"Error!", @"Added to log when cannot fetch objects from database"), error);
    }
    
    Podcast * latestPodcast;
    
    if(fetchedObjects.count < 1)
    {
        latestPodcast = [[Podcast alloc] initWithEntity:entity insertIntoManagedObjectContext:_managedObjectContext];
        latestPodcast.title = [NSDate distantPast];
        
        [self retreivePodcastsFromXML:latestPodcast];
        self.shouldSaveData = YES;
    }
    else
    {
        latestPodcast = [[self.fetchResultsController fetchedObjects] objectAtIndex:0];
        [self retreivePodcastsFromXML:latestPodcast];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.fetchResultsController = nil;
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
    
    cell.podcastLabel.text = [dateFormatter stringFromDate:cellPodcast.title];
    
    if([[cellPodcast.duration substringToIndex:2] isEqualToString:@"00"])
    {
        cell.lengthLabel.text = [cellPodcast.duration substringFromIndex:3];
    }
    else
    {
        cell.lengthLabel.text = cellPodcast.duration;
    }
    
    if( [cellPodcast.isPlayed isEqualToNumber:[[NSNumber alloc] initWithBool:NO]] || cellPodcast.isPlayed == nil)
    {
        cell.progressImageView.image = [UIImage imageNamed:@"unplayed-icon.png"];
    }
    else
    {
        if([cellPodcast.finished isEqualToNumber:[[NSNumber alloc] initWithBool:YES]])
        {
            //p.progress = 0;
        }
        else
        {
            cell.progressImageView.image = [UIImage imageNamed:@"half-played-icon.png"];
        }
    }

    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Podcast * selectedPodcast = [self.fetchResultsController objectAtIndexPath:indexPath];
    
    
    
    /*
    
    NSString * podcastPath = [[NSString alloc] initWithString:selectedPodcast.audioPath];
    
    NSURL * podcastURL = [[NSURL alloc] initWithString:podcastPath];
    
    [self streamAudioAt:podcastURL];
    
    selectedPodcast.isPlayed = [NSNumber numberWithBool:YES];
    
    [self saveData];
    
    MPMusicPlayerController * player = [MPMusicPlayerController applicationMusicPlayer];
    
    [player setShuffleMode:MPMusicShuffleModeOff];*/
    
}


- (void) fetchData
{
    NSError * error;
    
    if( ![[self fetchResultsController] performFetch:&error] )
    {
        NSLog(@"%@! %@",NSLocalizedString(@"Error!", @"Added to log when cannot fetch objects from database"), error);
        abort();
    }
    else
    {
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

- (void) reloadData
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.tableView reloadData];
}

#pragma mark - XML Traversing

- (void) retreivePodcastsFromXML: (Podcast *)latestPodcast
{
    //    NSString * podcastString = @"http://www.podcastgenerator.net/demo/pg/feed.xml";
    
    NSString * podcastString = @"http://www.radyoodtu.com.tr/podcasts/podcasts.asp?chid=1";

    TBXMLSuccessBlock successBlock = ^(TBXML *tbxmlDocument) {
        // If TBXML found a root node, process element and iterate all children
        if (tbxmlDocument.rootXMLElement)
            [self traverseElement:tbxmlDocument.rootXMLElement withLatestPodcast:latestPodcast];
        [self fetchData];
    };
    
    
    TBXMLFailureBlock failureBlock = ^(TBXML *tbxmlDocument, NSError * error) {
        NSLog(@"Parsing error! %@ %@", [error localizedDescription], [error userInfo]);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    };
    
    _tbxmlParser = [[TBXML alloc] initWithURL:[NSURL URLWithString:podcastString] success:successBlock failure:failureBlock];
    
}

static NSString * titleString;
static NSString * durationString;
static NSString * audioAddressString;

- (void) traverseElement:(TBXMLElement *) rootElement withLatestPodcast:(Podcast *)latestPodcast
{
    
    NSEntityDescription * ped = [NSEntityDescription entityForName:@"Podcast" inManagedObjectContext:_managedObjectContext];
    
    TBXMLElement * dataElement;
    
    TBXMLElement * firstItem = [TBXML childElementNamed:@"channel" parentElement:rootElement];
    
    if( firstItem != nil )
    {
        firstItem = [TBXML childElementNamed:@"item" parentElement:firstItem];
        
        while(firstItem != nil)
        {
            dataElement = [TBXML childElementNamed:@"title" parentElement:firstItem];
            
            titleString = [TBXML textForElement:dataElement];
            
            dataElement = [TBXML childElementNamed:@"guid" parentElement:firstItem];
            
            audioAddressString = [TBXML textForElement:dataElement];
            
            audioAddressString = [audioAddressString stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
            
            dataElement = [TBXML childElementNamed:@"itunes:duration" parentElement:firstItem];
            
            durationString = [TBXML textForElement:dataElement];
            
            titleString = [titleString substringFromIndex:16];
            
            
            if(![[titleString substringToIndex:1] isEqualToString:@"~"])
            {
                _parsedPodcast = [[Podcast alloc] initWithEntity:ped insertIntoManagedObjectContext:_managedObjectContext];
                
                NSDate * parsedPodcastDate = [MSTableViewController parseDate:titleString format:@"dd/MM/yy"];
                
                _parsedPodcast.title = parsedPodcastDate;
                _parsedPodcast.duration = durationString;
                _parsedPodcast.audioPath = audioAddressString;
                _parsedPodcast.finished = NO;
                _parsedPodcast.isPlayed = NO;
                
                if(parsedPodcastDate < latestPodcast.title)
                {
                    [_managedObjectContext insertObject:_parsedPodcast];
                }
                else
                {
                    break;
                }
            }
            
            firstItem = firstItem->nextSibling;
        }
        
        [self saveData];
    }
}

- (void) saveData
{
    NSError * error;
    
    if(![_managedObjectContext save:&error])
    {
        NSLog(@"%@! %@",NSLocalizedString(@"There was an error while saving!", @"Added to log when cannot save objects to database"), error);
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
        
        NSSortDescriptor * sorter = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
        
        [request setSortDescriptors:[[NSArray alloc] initWithObjects:sorter, nil]];
        
        _fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"title" cacheName:nil];
        
        return _fetchResultsController;
    }
}

+ (NSDate*)parseDate:(NSString*)inStrDate format:(NSString*)inFormat {
    NSDateFormatter* dtFormatter = [[NSDateFormatter alloc] init];
    //[dtFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];//[NSLocale systemLocale]];
    [dtFormatter setDateFormat:inFormat];
    NSDate* dateOutput = [dtFormatter dateFromString:inStrDate];
    return dateOutput;
}

static AVPlayer * audioPlayer;
- (IBAction)downloadButtonPressed:(UIButton *)sender
{
    NSString * mp3Path = @"http://www.radyoodtu.com.tr/podcasts/mediaredirect.asp?ch=1&itid=2848&dummy.mp3?";
    NSURL * mp3URL = [[NSURL alloc] initWithString:mp3Path];
    
    [self.statusOverlay showLoadingWithMessage:@"Downloading" animated:YES];
    
    //[self streamAudioAt:mp3URL];
}

- (void)streamAudioAt:(NSURL *) url
{
    audioPlayer = [[AVPlayer alloc] initWithURL:url];
    
    [audioPlayer play];
}
@end
