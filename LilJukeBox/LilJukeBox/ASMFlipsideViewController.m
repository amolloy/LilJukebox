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
- (void)deleteAllSongs:(id)sender;

- (void)setupButtonStates;

@property (retain, nonatomic) UIActionSheet* deleteActionSheet;
@property (retain, nonatomic) UIBarButtonItem* trashButton;
@property (retain, nonatomic) UIBarButtonItem* addButton;

@end

@implementation ASMFlipsideViewController

@synthesize delegate = _delegate;
@synthesize mediaPickerController = _mediaPickerController;
@synthesize deleteActionSheet = _deleteActionSheet;
@synthesize trashButton = _trashButton;
@synthesize addButton = _addButton;

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

    UIBarButtonItem* doneButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                     target:self
                                                                                     action:@selector(done:)] autorelease];
    
    self.navigationItem.leftBarButtonItem = doneButtonItem;
    
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.trashButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                      target:self
                                                                      action:@selector(deleteAllSongs:)] autorelease];
    UIBarButtonItem* flexibleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil] autorelease];
    self.addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                    target:self
                                                                    action:@selector(addSongs:)] autorelease];
    
    NSArray* toolbarItems = [NSArray arrayWithObjects:self.trashButton, flexibleSpace, self.addButton, nil];
    [self setToolbarItems:toolbarItems animated:NO];
    
    [self setupButtonStates];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.trashButton = nil;
    self.addButton = nil;
    self.mediaPickerController = nil;
    self.deleteActionSheet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self setupButtonStates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger songCount = [[ASMSongCollection sharedSongCollection] songCount];
    
    if (songCount > 10)
    {
        self.navigationItem.title = NSLocalizedString(@"Too many songs selected, please remove some.", @"Message when there are too many songs selected");
        self.editing = YES;
    }
    else
    {
        self.navigationItem.title = @"";
    }

    [self setupButtonStates];

    return songCount;
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
        
        NSInteger songCount = [[ASMSongCollection sharedSongCollection] songCount];
        NSInteger songsRemaining = 10 - songCount;
        if (songsRemaining < 0)
        {
            songsRemaining = 0;
        }
        
        NSString* promptFmt = NSLocalizedString(@"Please pick up to %1$i songs", @"Pick 10 Songs");
        NSString* prompt = [NSString stringWithFormat:promptFmt,songsRemaining];
        
        self.mediaPickerController.prompt = prompt;
        self.mediaPickerController.delegate = self;
    }
    
    [self.navigationController presentModalViewController:self.mediaPickerController animated:YES];
}

- (void)deleteAllSongs:(id)sender
{
    self.deleteActionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Remove all songs, are you sure?", @"Prompt to delete all songs")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"No", @"Decline to remove all songs")
                                               destructiveButtonTitle:NSLocalizedString(@"Yes", @"Accept to remove all songs")
                                                    otherButtonTitles:nil] autorelease];

    if ([self.deleteActionSheet respondsToSelector:@selector(showFromBarButtonItem:animated:)])
    {
        [self.deleteActionSheet showFromBarButtonItem:self.trashButton
                                             animated:YES];
    }
    else
    {
        [self.deleteActionSheet showFromToolbar:self.navigationController.toolbar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex)
    {
        [[ASMSongCollection sharedSongCollection] removeAllSongs];
        [self.tableView reloadData];
    }
    
    self.deleteActionSheet = nil;
}

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    [[ASMSongCollection sharedSongCollection] mergeSongsWithCollection:mediaItemCollection];
    
    [self.tableView reloadData];
    
    self.mediaPickerController = nil;
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self.navigationController dismissModalViewControllerAnimated:YES];

    self.mediaPickerController = nil;
}

- (void)setupButtonStates
{
    NSInteger songCount = [[ASMSongCollection sharedSongCollection] songCount];
    BOOL isEditing = self.editing;
    
    self.navigationItem.leftBarButtonItem.enabled = !isEditing && (songCount <= 10);
    self.addButton.enabled = (songCount < 10);
    self.trashButton.enabled = (songCount > 0);
}
@end
