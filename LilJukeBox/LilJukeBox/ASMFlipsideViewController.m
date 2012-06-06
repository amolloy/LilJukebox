//
//  ASMFlipsideViewController.m
//  LilJukeBox
//
//  Created by Andrew Molloy on 5/24/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import "ASMFlipsideViewController.h"
#import "ASMSongCollection.h"

@interface ASMFlipsideViewController ()
- (void)addSongs:(id)sender;
- (void)done:(id)sender;
@end

@implementation ASMFlipsideViewController

@synthesize delegate = _delegate;
@synthesize mediaPickerController = _mediaPickerController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    UIBarButtonItem* doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                     target:self
                                                                                     action:@selector(done:)] autorelease];
    
    self.navigationItem.leftBarButtonItem = doneButtonItem;
    
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem* addSongsButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                         target:self
                                                                                         action:@selector(addSongs:)] autorelease];
    UIBarButtonItem* flexibleSpace1 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                     target:nil
                                                                                     action:nil] autorelease];
    UIBarButtonItem* flexibleSpace2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                     target:nil
                                                                                     action:nil] autorelease];
    
    NSArray* toolbarItems = [NSArray arrayWithObjects:flexibleSpace1, addSongsButtonItem, flexibleSpace2, nil];
    [self setToolbarItems:toolbarItems animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ASMSongCollection sharedSongCollection] songs] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SongCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (nil == cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    MPMediaItem* item = [[[ASMSongCollection sharedSongCollection] songs] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
    cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];    
    
    return cell;
}

- (void)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (void)addSongs:(id)sender
{
    if (nil == self.mediaPickerController)
    {
        self.mediaPickerController = [[[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio] autorelease];
        self.mediaPickerController.allowsPickingMultipleItems = YES;
        self.mediaPickerController.prompt = NSLocalizedString(@"Please pick up to 10 songs", @"Pick 10 Songs");
        self.mediaPickerController.delegate = self;
    }
    
    [self.navigationController presentModalViewController:self.mediaPickerController animated:YES];
}

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    [[ASMSongCollection sharedSongCollection] mergeSongsWithCollection:mediaItemCollection];
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[ASMSongCollection sharedSongCollection] removeSongAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [[ASMSongCollection sharedSongCollection] moveSongFromIndex:fromIndexPath.row
                                                        toIndex:toIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - Table view delegate


@end
